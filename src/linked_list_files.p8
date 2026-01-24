;==============================================================================
;---   
;---   Double linked list of files
;---   
;==============================================================================
;---   
;==============================================================================

files_cache {
    struct Entry {
        ^^Entry next           ; Next entry in the list
        ^^Entry prev           ; Previous entry in the list
        str name               ; Name (key)
        bool is_tagged
        uword blocks           ; store blocks or kb here?
        ubyte rec_num
    }

    ^^Entry head = 0           ; Head of the doubly linked list
    ^^Entry tail = 0           ; Tail of the doubly linked list
    ;^^Entry page_top = 0       ; Tail of the doubly linked list

    ubyte num_files,num_tagged = 0        ; Number of entries

    alias FILE_NAME_SIZE = files_folders.FILE_MAX_LEN
    const bool NOT_TAGGED = false
    const ubyte LEFT_COL = 32
    const ubyte TOP_ROW = 6
    str TAG_CHAR = cp437:"♦"

    ;txt.print_lit(cp437:"≈ IBM Pc ≈ ÇüéâäàåçêëèïîìÄ ░▒▓│┤╡╢╖╕╣║╗╝╜╛┐ ☺☻♥♦♣♠•◘○◙♂♀♪♫☼ ►◄↕‼¶§▬↨↑↓→←∟↔▲▼")
    
    ;--- vars for movement
    ubyte top_index = 0
    ubyte selected_line_on_page,num_visible_files
    ubyte max_lines = txt.height() - 12

    ^^Entry current
    ^^Entry item_tmp_ptr

    sub init_clear() { 
        helpers.print_strXY(LEFT_COL,TOP_ROW,cp437:"Reading...",theme.TXT_NORMAL,false)
        num_files = num_tagged = top_index = selected_line_on_page = num_visible_files = 0         ; Number of entries
    }

    
    sub key_page_down() {
        debug.say("p-down-HAS-BUG")
        ;--- BUG!  Scroll and do page up-dn
        ; if num_files > 0 {
        ;     ; next page of lines
        ;     unselect_line(selected_line_on_page)
        ;     if selected_line_on_page == max_lines - 1
        ;         repeat max_lines scroll_list_forward()

        ;     selected_line_on_page = num_visible_files - 1
        ;     select_line(selected_line_on_page)
        ;     print_stats()
        ; }
    }

    sub key_page_up() {
        debug.say("p-up-HAS-BUG")
        ;--- BUG!  Scroll and do page up-dn
        ; line_color(selected_line_on_page, theme.TXT_NORMAL)
        ; if selected_line_on_page==0
        ;     repeat max_lines scroll_list_backward()

        ; selected_line_on_page = 0
        ; select_line(0)
        ; print_stats() 
    }


    sub key_up() { 
        line_color(selected_line_on_page, theme.TXT_NORMAL)
        if selected_line_on_page > 0 {
            current = current.prev
            selected_line_on_page--
        } else if num_files > max_lines {
            scroll_list_backward()
        }

        line_color(selected_line_on_page, theme.ROW_HILIGHT)
        print_stats()
        ;debug.say2("rec num:",current.rec_num)
        ;debug.say2("top idx:",top_index)
    }
    
    
    sub scroll_list_backward() {
        if top_index > 0 {
            top_index--
            ; scroll the displayed list down 1
            scroll_txt_down(LEFT_COL, TOP_ROW, FILE_NAME_SIZE, max_lines, iso:' ')
            ; print new name at the top of the list
            txt.plot(LEFT_COL, TOP_ROW)
            current = current.prev
            print_filename(selected_line_on_page)
        }
    }
    

    sub key_down() {
        if num_files > 0 {
            line_color(selected_line_on_page, theme.TXT_NORMAL)
            if selected_line_on_page < num_visible_files - 1 {
                selected_line_on_page++ 
                current = current.next
            } else if num_files > max_lines {
                scroll_list_forward()
            }
                
            line_color(selected_line_on_page, theme.ROW_HILIGHT)
            print_stats()
        }
        ;debug.say2("rec num:",current.rec_num)
        ;debug.say2("top idx:",top_index)
    }


    sub scroll_list_forward() {
        if top_index + max_lines < num_files  {
            top_index++
            ; scroll the displayed list up 1
            scroll_txt_up(LEFT_COL,TOP_ROW,FILE_NAME_SIZE,max_lines,iso:' ')
            ; print new name at the bottom of the list
            txt.plot(LEFT_COL,TOP_ROW + max_lines - 1)
            current = current.next
            print_filename(selected_line_on_page)
        }
     
    }
    

    sub scroll_txt_down(ubyte col, ubyte row, ubyte width, ubyte height, ubyte fillchar) {
        alias y = main.y
        alias x = main.x
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
        alias y = main.y
        alias x = main.x
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


    sub show_not_logged(){
        clear_panel()
        helpers.print_strXY(LEFT_COL,TOP_ROW,cp437:"Not Logged",theme.TXT_NORMAL,false)
    }

    sub clear_panel(){
        ;--- clear panel/page
        alias i = main.i
        alias str_clear = main.g_tmp_str_buffer1
        void strings.copy(" " * files_folders.FILE_MAX_LEN_CLEAR, str_clear)
        for i in 0 to max_lines {
            helpers.print_strXY2(LEFT_COL,TOP_ROW + i,str_clear) 
        }
    }

    sub draw_files_2_scrn(ubyte select_this_line) {
        alias i = main.i
        
        txt.color2(theme.TXT_NORMAL & 15, theme.TXT_NORMAL>>4)
        num_visible_files = min(max_lines, num_files)

        clear_panel()
        if num_files == 0 {
            helpers.print_strXY2(LEFT_COL,TOP_ROW, iso:"No Files")
            return
        }

        ;current = head
        current = find_by_recnum(top_index+1)
        item_tmp_ptr = current
        for i in 0 to num_visible_files - 1  {
            print_filename(i)   
            current = current.next
        }
        current = item_tmp_ptr ;--- reset to top visible line
        line_color(select_this_line,theme.ROW_HILIGHT)
        selected_line_on_page = select_this_line
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
            strings_ext.concat_strings(TAG_CHAR,line,tmp_str9)
        } else {
            strings_ext.concat_strings(cp437:" ",line,tmp_str9)
        }
         strings_ext.pad_right(tmp_str9, pretty_str, ' ', FILE_NAME_SIZE) 
         return pretty_str
    }


     sub set_focus() {  ;--- called when changing from FILES - DIR panels
        if num_files == 0 return
        line_color(selected_line_on_page, theme.ROW_HILIGHT)
    }

    sub lost_focus() {  ;--- called when changing from FILES - DIR panels
        if num_files == 0 return
        line_color(selected_line_on_page, theme.TXT_NORMAL)
    }

    sub line_color(ubyte line, ubyte colors) {
        alias charpos = main.i
        cx16.r1L = line+TOP_ROW
        for charpos in LEFT_COL to FILE_NAME_SIZE + LEFT_COL {
            txt.setclr(charpos, cx16.r1L, colors)
        }
    }

    sub print_stats() {
        ; TODO needs refactor
        alias i = main.i
        alias real_num = main.j
        ;i = txt.height() - 6
        i = 3
        helpers.print_strXY(51,i,cp437:"[File:    Of:    Tagged:    ]",theme.BOXES,false)
        ;helpers.print_strXY(78,i,cp437:"]",theme.BOXES,false)
        helpers.print_strXY(57,i,conv.str_ub(selected_line_on_page + 1 + top_index),theme.TXT_NORMAL,false)
        helpers.print_strXY(64,i,conv.str_ub(num_files),theme.TXT_NORMAL,false)
        helpers.print_strXY(75,i,conv.str_ub(num_tagged),theme.TXT_NORMAL,false)

        ; str i2 = "?"*24
        ; str i1 = "?"*24
        ; strings_ext.concat_strings("top ndx:",conv.str_ub(top_index),i1)
        ; strings_ext.concat_strings("rec num:",conv.str_ub(current.rec_num),i2)
        ; helpers.print_strXY(52,50,"                     ",theme.TXT_NORMAL,false)
        ; helpers.print_strXY(52,51,"                     ",theme.TXT_NORMAL,false)
        ; helpers.print_strXY(52,50,i1,theme.TXT_NORMAL,false)
        ; helpers.print_strXY(52,51,i2,theme.TXT_NORMAL,false)

    }


    sub add(str name, uword blocks) {
        ;--- Create new entry

        ^^Entry new_record = arena_files.alloc(sizeof(Entry))
        ^^ubyte name_copy  = arena_files.alloc(strings.length(name) + 1)
        void strings.copy(name, name_copy)

        num_files++

        new_record.name = name_copy
        new_record.is_tagged = false
        new_record.blocks = blocks
        new_record.next = 0
        new_record.prev = 0
        new_record.rec_num = num_files 

        ;--- Add to the end of the doubly linked list
        if head == 0 { ;--- First entry
            head = new_record
            tail = new_record
        } else {       ;--- Add to the end
            tail.next = new_record
            new_record.prev = tail
            tail = new_record
        }   
    }
    
    sub tag_file(ubyte line_num,bool tag) {
        defer print_stats()
        defer key_down()
        if current.is_tagged == tag {
            return ;--- file already tagged or untagged
        }
        current.is_tagged = tag 
        if tag { num_tagged++ } else { num_tagged-- }  ;--- inc / decr       
        print_filename(line_num)
    }


    sub tag_all(bool tag){
        
        alias ndx = main.x
        alias last_selected = main.j
        alias lrec = main.y
        num_tagged = if tag then num_files else 0
        ;ubyte last_selected,lrec
        
        line_color(selected_line_on_page,theme.TXT_NORMAL)
        last_selected = selected_line_on_page
        lrec = current.rec_num

        ;--- tag everything
        current = head
        for ndx in 0 to files_cache.num_files - 1  {
            current.is_tagged = tag
            current = current.next
        }
        draw_files_2_scrn(last_selected)
        print_stats()
        current = find_by_recnum(lrec)

        ;=== debug crap!
        ; str i2 = "?"*24
        ; str i1 = "?"*24
        ; strings_ext.concat_strings("rec1:",conv.str_ub(lrec),i1)
        ; strings_ext.concat_strings("rec2:",conv.str_ub(current.rec_num),i2)
        ; helpers.print_strXY(2,50,"                     ",theme.TXT_NORMAL,false)
        ; helpers.print_strXY(2,51,"                     ",theme.TXT_NORMAL,false)
        ; helpers.print_strXY(2,50,i1,theme.TXT_NORMAL,false)
        ; helpers.print_strXY(2,51,i2,theme.TXT_NORMAL,false)
    }


    sub find_by_recnum(ubyte rec_num) -> ^^Entry {
        ^^Entry item = head
        while item != 0 {
            if item.rec_num == rec_num {
                return item
            }
            item = item.next
        }
        return 0  ; Not found - should not happen
    }




}

arena_files {
    ; Simple arena allocator
    uword buffer = memory("a_files", 6400, 0)
    uword next = buffer

    sub alloc(ubyte size) -> uword {
        defer next += size
        return next
    }

    sub free_all() {
        ; cannot free individual allocations only the whole arena at once
        ; UNTESTED!!! - assuming this resets the pointer to the top
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
    ;             line_color(inner_index,theme.TXT_NORMAL)
    ;             inner_index--
    ;             line_color(inner_index,theme.ROW_HILIGHT)
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
    ;                 line_color(inner_index,theme.TXT_NORMAL)
    ;                 inner_index++
    ;                 line_color(inner_index,theme.ROW_HILIGHT)
    ;             }
                
    ;         }
    ;         MOVE_PG_UP ->   { }
    ;         MOVE_PG_DN ->   { }
            
    ;     }   
    ;     debug.say2("inner index",inner_index)     
    ; }
    
