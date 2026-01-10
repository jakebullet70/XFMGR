
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
        ubyte rec_num
    }

    ^^Entry head = 0                       ; Head of the doubly linked list
    ^^Entry tail = 0                       ; Tail of the doubly linked list
    ubyte count = 0                        ; Number of entries

    ubyte selected = 0
    ubyte top_index 
    ubyte page_height = 15 ;txt.height() - 11

    const ubyte FILE_NAME_SIZE = 40
    const bool DIR_ENTRY = true
    const bool FILE_ENTRY = false
    const bool NOT_TAGGED = false
    const ubyte LEFT_COL = 2
    const ubyte TOP_ROW = 6

    const ubyte MOVE_UP    = 1
    const ubyte MOVE_DN    = 2
    const ubyte MOVE_PG_UP = 3
    const ubyte MOVE_PG_DN = 4
    

    sub init() { }

    sub add(str name, bool is_dir, bool tagged, uword blocks) {
        ;--- Create new entry

        ^^Entry new_record = arena.alloc(sizeof(Entry))
        ^^ubyte name_copy  = arena.alloc(strings.length(name) + 1)
        void strings.copy(name, name_copy)

        new_record.name = name_copy
        new_record.is_dir = is_dir
        new_record.is_tagged = tagged
        new_record.blocks = blocks
        new_record.next = 0
        new_record.prev = 0
        new_record.hash_next = 0
        new_record.rec_num = count + 1

        ;--- Add to the end of the doubly linked list
        if head == 0 {
            ;--- First entry
            head = new_record
            tail = new_record
        } else {
            ;--- Add to the end
            tail.next = new_record
            new_record.prev = tail
            tail = new_record
        }

        count++
    }


    sub find_by_recnum(ubyte rec_num) -> ^^Entry {
        ^^Entry current = head
        while current != 0 {
            if current.rec_num == rec_num {
                return current
            }
            current = current.next
        }

        return 0  ; Not found
    }



    sub draw_files_2_scrn() {
        alias i = main.i
        alias filename = main.g_tmp_str_buffer3
        alias tmp_str  = main.g_tmp_str_buffer1

        txt.color2(clr.TXT_NORMAL & 15, clr.TXT_NORMAL>>4)

        ;--- clear panel/page
        void strings.copy(" "*FILE_NAME_SIZE,tmp_str)
        for i in 0 to page_height - 1  {
            helpers.print_strXY2(LEFT_COL,TOP_ROW+i,tmp_str) 
        }

        ;--- print page
        ^^Entry current = head
        for i in 0 to page_height - 1  {
            void strings.copy(pretty_line(current.name,current.is_tagged),filename)
            helpers.print_strXY2(LEFT_COL,TOP_ROW+i,filename)
            current = current.next
            if i == count-1 { break }
        }

        highlight_line(MOVE_DN)
    }

    sub pretty_line(str line, bool tagged) -> str {
        ;--- make file name pretty
        alias pretty_str = main.g_tmp_str_buffer2 
        alias tmp_str9   = main.g_tmp_str_buffer1 
        if tagged {
            strings_ext.concat_strings(cp437:"*",line,tmp_str9)
        } else {
            strings_ext.concat_strings(cp437:" ",line,tmp_str9)
        }
         strings_ext.pad_right(tmp_str9, pretty_str, ' ', FILE_NAME_SIZE) 
         return pretty_str
    }

    sub highlight_line(ubyte up_down) {
        if count == 0 { return }
        ;--- TODO --->  HAVE TO ADD PAGE UP/DN 
        when up_down {
            MOVE_UP ->      { 
                if selected == 1 { return }
                highlight_line_unhighlight(selected+TOP_ROW-1)
                selected--
                highlight_line_highlight(selected+TOP_ROW-1)           
            }
            MOVE_DN ->      { 
                highlight_line_unhighlight(selected+TOP_ROW-1)
                selected++
                highlight_line_highlight(selected+TOP_ROW-1)
            }
            MOVE_PG_UP ->   { }
            MOVE_PG_DN ->   { }
        }
        
    }

    sub highlight_line_highlight(ubyte row) {
        alias i = main.i
        for i in LEFT_COL to FILE_NAME_SIZE + LEFT_COL {
            txt.setclr(i,selected+TOP_ROW-1,clr.ROW_HILIGHT)
        }
    }
    sub highlight_line_unhighlight(ubyte row) {
        alias i = main.i
        for i in LEFT_COL to FILE_NAME_SIZE + LEFT_COL {
            txt.setclr(i,selected+TOP_ROW-1,clr.TXT_NORMAL)
        }
    }

    sub scroll_txt_up(ubyte col, ubyte row, ubyte width, ubyte height, ubyte fillchar) {
        alias y = main.i
        alias x = main.j
        for y in row to row+height-2 {
            for x in col to col+width-1 {
                txt.setchr(x,y, txt.getchr(x, y+1))
            }
        }
        y = row+height-1
        for x in col to col+width-1 {
            txt.setchr(x,y, fillchar)
        }
    }

    sub scroll_txt_down(ubyte col, ubyte row, ubyte width, ubyte height, ubyte fillchar) {
        alias y = main.i
        alias x = main.j
        for y in row+height-1 downto row+1 {
            for x in col to col+width-1 {
                txt.setchr(x,y, txt.getchr(x, y-1))
            }
        }
        for x in col to col+width-1 {
            txt.setchr(x,row, fillchar)
        }
    }



}

arena {
    ; Simple arena allocator
    uword buffer = memory("arena", 8000, 0)
    uword next = buffer

    sub alloc(ubyte size) -> uword {
        defer next += size
        return next
    }

    sub free_all() {
        ; cannot free individual allocations only the whole arena at once
        ; UNTESTED!!!
        next = buffer
    }
}



    ; sub print_forward() {
    ;     ^^Entry current = head
    ;     while current != 0 {
    ;         txt.print("- ")
    ;         txt.print(current.name)
    ;         txt.print(" (dir:")
    ;         txt.print_bool(current.is_dir)
    ;         txt.print(", ")
    ;         txt.print(" (tagged:")
    ;         txt.print_bool(current.is_tagged)
    ;         txt.print(")\n")
    ;         current = current.next
    ;     }
    ;     txt.print("Total entries: ")
    ;     txt.print_uw(count)
    ;     txt.print("\n")
    ; }

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

    

    ; sub find_by_filename(str name) -> ^^Entry {
    ;     ^^Entry current = head
    ;     while current != 0 {
    ;         if strings.compare(current.name, name) == 0
    ;             return current
    ;         ;current = current.hash_next
    ;         current = current.next
    ;     }

    ;     return 0  ; Not found
    ; }

    

    ; sub remove(str name) -> bool {
    ;     ; Find the entry
    ;     ^^Entry to_remove = find(name)
    ;     if to_remove == 0
    ;         return false  ; Not found

    ;     ; Remove from doubly linked list
    ;     if to_remove.prev != 0
    ;         to_remove.prev.next = to_remove.next
    ;     else
    ;         head = to_remove.next  ; Was the head

    ;     if to_remove.next != 0
    ;         to_remove.next.prev = to_remove.prev
    ;     else
    ;         tail = to_remove.prev  ; Was the tail

    ;     count--
    ;     return true
    ; }
