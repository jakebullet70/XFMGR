;==============================================================================
;---   
;---   Double linked list of folders
;---   
;==============================================================================
;---   
;==============================================================================

dirs_cache {
    struct Entry {
        ^^Entry next          ; Next entry in the list
        ^^Entry prev          ; Previous entry in the list
        str name              ; Name (key)
        bool is_expanded
        bool has_children
        bool visible
        bool logged
        ubyte level           ; indentation level (0 = root)
        ubyte rec_num
    }

    ^^Entry head = 0                       ; Head of the doubly linked list
    ^^Entry tail = 0                       ; Tail of the doubly linked list

    ubyte num_dirs = 0                    ; Number of entries
    ;alias DIR_NAME_SIZE = files_folders.FILE_MAX_LEN
    const ubyte DIR_NAME_SIZE = 27


    const ubyte LEFT_COL = 2
    const ubyte TOP_ROW = 6
    const ubyte LEVEL_SIZE = 3
    
    ;--- vars for movement
    ubyte top_index = 0
    ubyte selected_line,num_visible_dirs
    ubyte max_lines = txt.height() - 12

    ^^Entry current

    sub init_clear() { 
       selected_line = num_visible_dirs = num_dirs = top_index = 0 
    }

    sub key_page_down() {
        debug.say("p-down-HAS-BUG")
        ;--- BUG!  Scroll and do page up-dn
        ; if num_dirs > 0 {
        ;     ; next page of lines
        ;     unselect_line(selected_line)
        ;     if selected_line == max_lines - 1
        ;         repeat max_lines scroll_list_forward()

        ;     selected_line = num_visible_dirs - 1
        ;     select_line(selected_line)
        ;     print_stats()
        ; }
    }

    sub key_page_up() {
        debug.say("p-up-HAS-BUG")
        ;--- BUG!  Scroll and do page up-dn
        ; line_color(selected_line, theme.TXT_NORMAL)
        ; if selected_line==0
        ;     repeat max_lines scroll_list_backward()

        ; selected_line = 0
        ; select_line(0)
        ; print_stats() 
    }

    sub key_up() { 
        if selected_line + top_index == 0 return ;--- already at top
        line_color(selected_line, theme.TXT_NORMAL)
        if selected_line > 0 {
            current.logged = false
            current = current.prev
            selected_line--
        } else if num_dirs>max_lines {
            scroll_list_backward()
        }

        show_new_folder_or_not_logged()
        ;debug.say2("rec num:",current.rec_num)
        ;debug.say2("top idx:",top_index)
    }
    
    
    sub scroll_list_backward() {
        if top_index > 0 {
            top_index--
            ; scroll the displayed list down 1
            scroll_txt_down(LEFT_COL, TOP_ROW, DIR_NAME_SIZE, max_lines, iso:' ')
            ; print new name at the top of the list
            txt.plot(LEFT_COL, TOP_ROW)
            current = current.prev
            print_dir_name(selected_line)
        }
    }
    
    sub key_down() {
        if selected_line + top_index + 1 == num_dirs  return ;--- already at bottom
        if num_dirs > 0 {
            line_color(selected_line, theme.TXT_NORMAL)
            if selected_line < num_visible_dirs - 1 {
                current.logged = false
                selected_line++ 
                current = current.next
            } else if num_dirs > max_lines {
                scroll_list_forward()
            }
            show_new_folder_or_not_logged()    
        }
        ;debug.say2("rec num:",current.rec_num)
        ;debug.say2("top idx:",top_index)
    }

    sub show_new_folder_or_not_logged() {
        ;debug.say2(current.name,current.rec_num)
        line_color(selected_line, theme.ROW_HILIGHT)
        if current.rec_num == 1 { ;--- ONLY read ROOT?
            main.read_files(diskio.drivenumber,files_folders.filter_files,"/")
            files_cache.print_stats()
        }  else {
            files_cache.show_not_logged()
        }
        print_stats() ;-- dir stats
    }

    sub scroll_list_forward() {
        if top_index + max_lines < num_dirs  {
            top_index++
            ; scroll the displayed list up 1
            scroll_txt_up(LEFT_COL,TOP_ROW,DIR_NAME_SIZE,max_lines,iso:' ')
            ; print new name at the bottom of the list
            txt.plot(LEFT_COL,TOP_ROW + max_lines - 1)
            current = current.next
            print_dir_name(selected_line)
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

    sub draw_dirs_2_scrn() {
        alias i = main.i
        alias str_clear = main.g_tmp_str_buffer1

        txt.color2(theme.TXT_NORMAL & 15, theme.TXT_NORMAL>>4)
        num_visible_dirs = min(max_lines, num_dirs)
        ;debug.say2("num dir",num_dirs)

        ;--- clear panel/page
        void strings.copy(" "*DIR_NAME_SIZE,str_clear)
        for i in 0 to max_lines {
            helpers.print_strXY2(LEFT_COL,TOP_ROW + i,str_clear) 
        }        
        ; if num_dirs == 0 {
        ;     helpers.print_strXY2(LEFT_COL,TOP_ROW + 1,iso:"No Directories")
        ;     return
        ; }

        ;^^Entry current = head
        current = head
        for i in 0 to num_visible_dirs - 1  {
            print_dir_name(i)   
            current = current.next
        }

        current = head ;--- reset to top
        line_color(0,theme.ROW_HILIGHT)
        selected_line = 0
    }

    sub print_dir_name(ubyte row) {
        ;^^Entry current is the pointer to the linked list
        alias dir_name = main.g_tmp_str_buffer3
        void strings.copy(pretty_line(current.name,current.is_expanded),dir_name)
        helpers.print_strXY2(LEFT_COL + (current.level * LEVEL_SIZE),TOP_ROW + row,dir_name)
    }

    sub pretty_line(str line, bool is_expanded) -> str {
        ;--- make dir name pretty
        alias pretty_str = main.g_tmp_str_buffer2 
        alias tmp_str9   = main.g_tmp_str_buffer1 
        ;chr_tleft
        if current.rec_num == 1 { ;--- ROOT
            strings_ext.concat_strings(cp437:"",line,tmp_str9)
        } else if is_expanded {
            strings_ext.concat_strings(cp437:" ├─",line,tmp_str9)
        } else {
            strings_ext.concat_strings(cp437:"+├─",line,tmp_str9)
        }
        strings_ext.pad_right(tmp_str9, pretty_str, ' ', DIR_NAME_SIZE) 
        return pretty_str
    }

    sub set_focus() {
        line_color(selected_line, theme.ROW_HILIGHT)
    }

    sub lost_focus() {
        line_color(selected_line, theme.TXT_NORMAL)
    }

    sub line_color(ubyte line, ubyte colors) {
        alias charpos = main.i
        alias start_col = main.j
        cx16.r1L = line+TOP_ROW
        start_col = 2 + LEFT_COL + (current.level * LEVEL_SIZE)
        if current.rec_num == 1 { start_col = LEFT_COL }
        
        for charpos in start_col to DIR_NAME_SIZE + LEFT_COL {
            txt.setclr(charpos, cx16.r1L, colors)
        }
    }

    sub print_stats() {
        ;--- stats on folders
    }

    sub create(str name, ubyte level) -> ^^Entry {
        ^^Entry new_record = arena_dirs.alloc(sizeof(Entry))
        ^^ubyte name_copy  = arena_dirs.alloc(strings.length(name) + 1)
        void strings.copy(name, name_copy)

        num_dirs++

        new_record.name = name_copy
        new_record.is_expanded = false
        new_record.level = level
        new_record.has_children = false
        new_record.visible = true
        new_record.logged = false
        new_record.next = 0
        new_record.prev = 0
        new_record.rec_num = num_dirs

        return new_record
    }

    sub add(str name, ubyte level) {
        ;--- Create new entry
        ^^Entry new_record = create(name, level)

        ;--- Add to the end of the doubly linked list
        if head == 0 {  ;--- First entry
            head = new_record
            tail = new_record
        } else {        ;--- Add to the end
            tail.next = new_record
            new_record.prev = tail
            tail = new_record
        }
    }

    sub insert(str name, ubyte level, ^^Entry previous_entry, bool as_child) {

        ^^Entry new_record = create(name, level)

        ;== Configure new record as child of previous entry
        if (as_child) {
            previous_entry.has_children = true
            new_record.level = previous_entry.level + 1

        }

        ;== Link new record to surrounding records
        new_record.next = previous_entry.next
        previous_entry.next = new_record
        new_record.prev = previous_entry
        new_record.next.prev = new_record
    }
}


arena_dirs {
    ; Simple arena allocator
    uword buffer = memory("a_dirs", 3200, 0)
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


