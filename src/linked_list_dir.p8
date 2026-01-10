
; -----------------------------------
; --- Linked list holding the Dir
; -----------------------------------

dir_cache {
    struct Entry {
        ^^Entry next          ; Next entry in the list
        ^^Entry prev          ; Previous entry in the list
        str name              ; Name (key)
        bool is_dir
        bool is_tagged
        uword blocks
        ubyte rec_num
    }

    ^^Entry head = 0                       ; Head of the doubly linked list
    ^^Entry tail = 0                       ; Tail of the doubly linked list

    ubyte num_files = 0                        ; Number of entries

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
    const ubyte LAST_MOVE_UP = 1
    const ubyte LAST_MOVE_DN = 2
    ubyte LAST_MOVE = 0

    ubyte top_index = 0
    ubyte selected_line,num_visible_files
    ubyte max_lines = 15 ;txt.height() - 11

    ^^Entry current

    sub init() { }

    sub key_up() { 
        ;if LAST_MOVE == LAST_MOVE_DN { current = current.next }
        ;LAST_MOVE = LAST_MOVE_UP
        unselect_line(selected_line)
        if selected_line > 0 {
            current = current.prev
            selected_line--
        } else if num_files>max_lines {
            scroll_list_backward()
        }

        select_line(selected_line)
        print_up_and_down()
        debug.say2("rec num:",current.rec_num)
    }
    
    
    sub scroll_list_backward() {
        if top_index > 0 {
            top_index--
            ; scroll the displayed list down 1
            scroll_txt_down(LEFT_COL, TOP_ROW, FILE_NAME_SIZE, max_lines, iso:' ')
            ; print new name at the top of the list
            txt.plot(LEFT_COL, TOP_ROW)
            current = current.prev
            print_filename(top_index + selected_line)
        }
    }
    


    sub key_down() {
        if num_files > 0 {
            ;if LAST_MOVE == LAST_MOVE_UP { current = current.prev }
            ;LAST_MOVE = LAST_MOVE_DN
            line_color(selected_line, clr.TXT_NORMAL)
            if selected_line < num_visible_files - 1 {
                selected_line++ 
                current = current.next
            } else if num_files>max_lines {
                scroll_list_forward()
            }
                
            line_color(selected_line, clr.ROW_HILIGHT)
            print_up_and_down()
        }
        debug.say2("rec num:",current.rec_num)
    }


    sub scroll_list_forward() {
        if top_index + max_lines < num_files - 1 {
            top_index++
            ; scroll the displayed list up 1
            scroll_txt_up(LEFT_COL,TOP_ROW,FILE_NAME_SIZE,max_lines,iso:' ')
            ; print new name at the bottom of the list
            txt.plot(LEFT_COL,TOP_ROW + max_lines - 1)
            current = current.next
            print_filename(selected_line)
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

    sub draw_files_2_scrn() {
        alias i = main.i
        alias str_clear = main.g_tmp_str_buffer1

        txt.color2(clr.TXT_NORMAL & 15, clr.TXT_NORMAL>>4)
        num_visible_files = min(max_lines, num_files)

        ;--- clear panel/page
        void strings.copy(" "*FILE_NAME_SIZE,str_clear)
        for i in 0 to num_visible_files - 1  {
            helpers.print_strXY2(LEFT_COL,TOP_ROW + i,str_clear) 
        }
        
        ;^^Entry current = head
        current = head
        for i in 0 to num_visible_files - 1  {
            print_filename(i)   
            current = current.next
        }

        current = head ;--- reset to top
        line_color(0,clr.ROW_HILIGHT)
        selected_line = 0
    }

    sub print_filename(ubyte row) {
        ;^^Entry current is the pointer to the linked list
        alias filename = main.g_tmp_str_buffer3
        void strings.copy(pretty_line(current.name,current.is_tagged),filename)
        helpers.print_strXY2(LEFT_COL,TOP_ROW + row,filename)
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

    sub select_line(ubyte line) {
        line_color(line, clr.ROW_HILIGHT)
    }

    sub unselect_line(ubyte line) {
        line_color(line, clr.TXT_NORMAL)
    }

    sub line_color(ubyte line, ubyte colors) {
        alias charpos = main.i
        cx16.r1L = line+TOP_ROW
        for charpos in LEFT_COL to FILE_NAME_SIZE + LEFT_COL {
            txt.setclr(charpos, cx16.r1L, colors)
        }
    }

    sub print_up_and_down() {

    }



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
        new_record.rec_num = num_files + 1

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

        num_files++
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
    ;     txt.print_uw(num_files)
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
    ;     txt.print_uw(num_files)
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

    ;     num_files--
    ;     return true
    ; }


    ; sub movement_line(ubyte movement) {
        
    ;     if num_files == 0 { return } ;--- no files
    ;     ;--- TODO --->  HAVE TO ADD PAGE UP/DN 
    ;     when movement {
    ;         MOVE_UP ->      { 
    ;             if pages_index == 1 and inner_index == 1 { return } ;--- top
    ;             line_color(inner_index,clr.TXT_NORMAL)
    ;             inner_index--
    ;             line_color(inner_index,clr.ROW_HILIGHT)
    ;         }
    ;         MOVE_DN ->      {
    ;             if pages_index * inner_index == num_files { 
    ;                 debug.say("MOVE_DN-LAST ENTRY")
    ;                 return  ;--- bottom
    ;             }
                    
    ;             if (inner_index) == page_height {
    ;                 scroll_txt_up(LEFT_COL,TOP_ROW,FILE_NAME_SIZE,page_height,' ')
    ;                 pages_index++
    ;             } else {
    ;                 ;debug.say2("inner index",inner_index)
    ;                 line_color(inner_index,clr.TXT_NORMAL)
    ;                 inner_index++
    ;                 line_color(inner_index,clr.ROW_HILIGHT)
    ;             }
                
    ;         }
    ;         MOVE_PG_UP ->   { }
    ;         MOVE_PG_DN ->   { }
            
    ;     }   
    ;     debug.say2("inner index",inner_index)     
    ; }
    

    ; sub find_by_recnum(ubyte rec_num) -> ^^Entry {
    ;     ^^Entry current = head
    ;     while current != 0 {
    ;         if current.rec_num == rec_num {
    ;             return current
    ;         }
    ;         current = current.next
    ;     }

    ;     return 0  ; Not found
    ; }


