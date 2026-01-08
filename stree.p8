%import diskio
%import textio
%import strings
%import syslib  

;%encoding "petscii"
%import namesorting
%option no_sysinit
%zeropage basicsafe

menu_modes {
    const ubyte DIR  = 0
    const ubyte ALT  = 1
    const ubyte FILE = 2
    const ubyte CTRL = 3
    ubyte mode

    sub draw_menu_type(str tmp1) {
        helpers.print_strXY(1,txt.height() - 4," " * 78,clr.MENU_NORMAL,false)
        helpers.print_strXY(1,txt.height() - 3," " * 78,clr.MENU_NORMAL,false)
        helpers.print_strXY(1,txt.height() - 2," " * 78,clr.MENU_NORMAL,false)
        helpers.print_strXY(1,txt.height() - 4,tmp1,clr.MENU_NORMAL,false)
        helpers.print_strXY(1,txt.height() - 3,iso:"COMMANDS",clr.MENU_NORMAL,false)
    }

    sub draw() {
    ;''sub print_strXY(ubyte col, ubyte row, str txtstring, ubyte colors, bool convertchars) {'    
        when mode {
            DIR ->  { draw_menu_type(iso:"DIR") } 
            FILE -> { draw_menu_type(iso:"FILE")} 
            ALT ->  { draw_menu_type(iso:"ALT") } 
            CTRL -> { draw_menu_type(iso:"CTRL")} 
        }
    }
}

main {
    ;--- tmp vars to be used wherever
    str g_tmp_str_buffer1 = "?" * 80
    str g_tmp_str_buffer2 = "?" * 255
    ubyte i,j = 0
    bool bool_tmp = false

    sub start() {

        cx16.set_screen_mode(0)
        txt.color2(clr.TXT_NORMAL & 15, clr.TXT_NORMAL>>4)
        txt.clear_screen()        
        
        txt.cp437()                     ;--- enable ISO character set 
        txt.lowercase()
        helpers.set_characters(true)    ;--- use ISO characters for box drawing
        helpers.draw_main_scrn()

        menu_modes.mode = menu_modes.DIR ;--- default for the moment
        menu_modes.draw()

        dir_cache.init()
        void files_folders.read(8)
        txt.plot(4,4)
        dir_cache.print_forward()

    ;--- main character input loop       
    char_loop:
        ubyte char
        void, char = cbm.GETIN()
        if char == 0
            goto char_loop

        when char {
            27 -> { goto end_me }  ; ESC key to end program

        }

        goto char_loop

    end_me:
        txt.uppercase()
        txt.color2(0,3)
        ;txt.color2(colors & 15, colors>>4)
        txt.print("BYE!")
        return

    }

}


files_folders {

    bool disk_error = false
    ubyte total_dir, total_files = 0
    alias tmp_str = main.g_tmp_str_buffer2 
    const bool DIR_ENTRY = true
    const bool FILE_ENTRY = false
    const bool NOT_TAGGED = false
    
    sub read(ubyte drv) -> bool { 
        diskio.drivenumber = drv

        ;--- list directories first
        if diskio.lf_start_list_dirs(0) {
            while diskio.lf_next_entry() {    
                void strings.copy(diskio.list_filename, tmp_str)
                void strings.lower(tmp_str)    
                dir_cache.add(tmp_str,DIR_ENTRY,NOT_TAGGED,0)
                total_dir++   
            }
        } else {
            disk_error = true
        }
        diskio.lf_end_list()

        ;--- then list files
        if diskio.lf_start_list_files(0) and not disk_error {
            while diskio.lf_next_entry() {
                void strings.copy(diskio.list_filename, tmp_str)
                void strings.lower(tmp_str)    
                dir_cache.add(tmp_str,FILE_ENTRY,NOT_TAGGED,diskio.list_blocks)
                total_files++       
            }
        } else {
            disk_error = true
        }
        diskio.lf_end_list()

        return disk_error
    }

}


; -----------------------------------
; --- Linked list holding the Dir
; -----------------------------------

dir_cache {
    struct Entry {
        ^^Entry next          ; Next entry in the list
        ^^Entry prev          ; Previous entry in the list
        ^^Entry hash_next     ; Next entry in the hash bucket
        str name              ; Name (key)
        bool is_dir
        bool is_tagged
        uword blocks
    }

    ;const ubyte HASH_TABLE_SIZE = 199
    ;^^Entry[HASH_TABLE_SIZE] hash_table    ; Hash table for fast lookups
    ^^Entry head = 0                       ; Head of the doubly linked list
    ^^Entry tail = 0                       ; Tail of the doubly linked list
    uword count = 0                        ; Number of entries

    sub init() {
        ; Initialize hash table buckets to null
        ;sys.memsetw(hash_table, HASH_TABLE_SIZE, 0)
    }

    
    sub add(str name, bool is_dir, bool tagged, uword blocks) {
        ;--- Create new entry

        ^^Entry new_record = arena.alloc(sizeof(Entry))

        ^^ubyte name_copy = arena.alloc(strings.length(name) + 1)
        void strings.copy(name, name_copy)

        new_record.name = name_copy
        new_record.is_dir = is_dir
        new_record.is_tagged = tagged
        new_record.blocks = blocks
        new_record.next = 0
        new_record.prev = 0
        new_record.hash_next = 0

        ; Add to the end of the doubly linked list
        if head == 0 {
            ; First entry
            head = new_record
            tail = new_record
        } else {
            ; Add to the end
            tail.next = new_record
            new_record.prev = tail
            tail = new_record
        }

        ; ; Add to hash table
        ; ubyte bucket = strings.hash(name) % HASH_TABLE_SIZE
        ; new_record.hash_next = hash_table[bucket]
        ; hash_table[bucket] = new_record

        count++
    }


    sub find(str name) -> ^^Entry {
        ; Find entry using hash table for O(1) average case

         ;ubyte bucket = strings.hash(name) % HASH_TABLE_SIZE
         ;^^Entry current = hash_table[bucket]

        ^^Entry current = head

        while current != 0 {
            if strings.compare(current.name, name) == 0
                return current
            ;current = current.hash_next
            current = current.next
        }

        return 0  ; Not found
    }

    sub remove(str name) -> bool {
        ; Find the entry
        ^^Entry to_remove = find(name)
        if to_remove == 0
            return false  ; Not found

        ; Remove from doubly linked list
        if to_remove.prev != 0
            to_remove.prev.next = to_remove.next
        else
            head = to_remove.next  ; Was the head

        if to_remove.next != 0
            to_remove.next.prev = to_remove.prev
        else
            tail = to_remove.prev  ; Was the tail

        ; ; Remove from hash table
        ; ubyte bucket = strings.hash(name) % HASH_TABLE_SIZE
        ; if hash_table[bucket] == to_remove {
        ;     hash_table[bucket] = to_remove.hash_next
        ; } else {
        ;     ^^Entry current = hash_table[bucket]
        ;     while current.hash_next != 0 {
        ;         if current.hash_next == to_remove {
        ;             current.hash_next = to_remove.hash_next
        ;             break
        ;         }
        ;         current = current.hash_next
        ;     }
        ;}

        count--
        return true
    }

    sub print_forward() {
        ^^Entry current = head
        while current != 0 {
            txt.print("- ")
            txt.print(current.name)
            txt.print(" (dir:")
            txt.print_bool(current.is_dir)
            txt.print(", ")
            txt.print(" (tagged:")
            txt.print_bool(current.is_tagged)
            txt.print(")\n")
            current = current.next
        }
        txt.print("Total entries: ")
        txt.print_uw(count)
        txt.print("\n")
    }

    ; sub print_backward() {
    ;     ^^Entry current = tail
    ;     while current != 0 {
    ;         txt.print("- ")
    ;         txt.print(current.name)
    ;         txt.print(" (dir:")
    ;         txt.print_bool(current.is_dir)
    ;         txt.print(", ")
    ;         txt.print(" (is_tagged:")
    ;         txt.print_bool(current.is_tagged)
    ;         txt.print(")\n")
    ;         current = current.prev
    ;     }
    ;     txt.print("Total entries: ")
    ;     txt.print_uw(count)
    ;     txt.print("\n")
    ; }
}

arena {
    ; Simple arena allocator
    uword buffer = memory("arena", 8000, 0)
    uword next = buffer

    sub alloc(ubyte size) -> uword {
        defer next += size
        return next
    }
}

; -----------------------------------
; --- Misc stuff
; -----------------------------------

clr {
    ;--- default colors
    const ubyte TXT_NORMAL = $b1  ; 
    const ubyte TXT_BRIGHT = $b1  ; 
    const ubyte MENU_NORMAL = $b1  ;
    const ubyte MENU_BRIGHT = $b7  ; 
    const ubyte BOXES = $be ;
}

;--- misc functions
helpers {
    ubyte chr_topleft, chr_topright, chr_botleft, chr_botright
    ubyte chr_tleft, chr_tright, chr_tup, chr_tdown, chr_horiz, chr_vert

    sub print_strXY(ubyte col, ubyte row, str txtstring, ubyte colors, bool convertchars) {
        txt.plot(col,row)
        txt.color2(colors & 15, colors>>4)
        txt.print_lit(txtstring)
    }

    sub plot_charXY(ubyte col, ubyte row, ubyte char, ubyte colors) {
        txt.setcc2(col,row,char,colors)
    }  

    sub draw_box(ubyte col, ubyte row, ubyte width, ubyte height, ubyte colors) {

        alias i = main.i        ;--- re-use vars
        alias rows = main.j     ;--- re-use vars
        rows = txt.height()
        pokew(903,65) ;--- change scrn height so no scroll  

        draw_vert_line(col,row,width)
        txt.plot(col,row)
        txt.chrout_lit(chr_topleft)
        txt.plot(col+width-1,row)
        txt.chrout_lit(chr_topright)

        for i in 1 to height - 2 {
             txt.plot(col,row+i)
             txt.chrout_lit(chr_vert)
             txt.plot(col+width-1,row+i)
             txt.chrout_lit(chr_vert)
        }
        
        draw_vert_line(col,row+height-1,width)
        txt.plot(col,row+height-1)
        txt.chrout_lit(chr_botleft)
        txt.plot(col+width-1,row+height-1)
        txt.chrout_lit(chr_botright)
        pokew(903,rows)   ;--- restore screen height    
    }

    sub set_characters(bool iso_chars) {
        if iso_chars {
            chr_topleft = 218 
            chr_topright = 191
            chr_botleft = 192 
            chr_botright = 217 
            chr_vert = 179 
            chr_horiz = 196 
            chr_tleft = 195
            chr_tright = 180
            chr_tup = 193
            chr_tdown = 194
        } else {
            ; PETSCII box symbols
            chr_topleft = '┌'
            chr_topright = '┐'
            chr_botleft = '└'
            chr_botright = '┘'
            chr_horiz = '─'
            chr_vert = '│' 
            chr_tleft = '├'
            chr_tright = '┤'
        }
    }

    sub draw_main_scrn() {
        txt.clear_screen()
        draw_box(0,0,txt.width(), txt.height(), clr.BOXES)
        draw_vert_line(0,txt.height() - 5,80)
        draw_vert_line(0,2,80)
        draw_vert_line(0,4,80)
        print_strXY(1 ,1,iso:"XFMGR V0.1.0",clr.TXT_NORMAL,false)
        print_strXY(63,1,iso:"Dec 29 - 02:30PM",clr.TXT_NORMAL,false)
}

    sub draw_vert_line(ubyte col,ubyte row, ubyte width){
        txt.plot(col,row)
        txt.color2(clr.BOXES & 15, clr.BOXES>>4)
        repeat width {txt.chrout_lit(chr_horiz)}
        plot_charXY(col,row,chr_tleft,clr.BOXES)
        plot_charXY(col+width-1,row,chr_tright,clr.BOXES)
    }

}



