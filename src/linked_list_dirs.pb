'==============================================================================
'---   
'---   Double linked list of folders
'---   
'==============================================================================
'---   
'==============================================================================
IMPORT textio
IMPORT stree
IMPORT helpers
IMPORT strings_ext
IMPORT strings

MODULE dirs_cache
    TYPE Entry
        nextEntry AS ^^Entry          ' Next entry in the list
        prevEntry AS ^^Entry          ' Previous entry in the list
        name AS STRING              ' Name (key)
        is_expanded AS BOOL
        has_children AS BOOL
        visible AS BOOL
        logged AS BOOL
        level AS UBYTE           ' indentation level (0 = root)
        rec_num AS UBYTE
    END TYPE

    DIM head AS ^^Entry = 0                       ' Head of the doubly linked list
    DIM tail AS ^^Entry = 0                       ' Tail of the doubly linked list

    DIM num_dirs AS UBYTE = 0                    ' Number of entries
    'alias DIR_NAME_SIZE = files_folders.FILE_MAX_LEN
    CONST DIR_NAME_SIZE AS UBYTE = 27


    CONST LEFT_COL AS UBYTE = 2
    CONST TOP_ROW AS UBYTE = 6
    CONST LEVEL_SIZE AS UBYTE = 3
    
    '--- vars for movement
    DIM top_index AS UBYTE = 0
    DIM selected_line_on_page, num_visible_dirs AS UBYTE
    DIM max_lines AS UBYTE = txt.height() - 12

    DIM current AS ^^Entry

    SUB init_clear() 
       selected_line_on_page = num_visible_dirs = num_dirs = top_index = 0 
    END SUB

    SUB key_page_down() 
        debug.say("p-down-HAS-BUG")
        '--- BUG!  Scroll and do page up-dn
        ' if num_dirs > 0 {
        '     ' next page of lines
        '     unselect_line(selected_line_on_page)
        '     if selected_line_on_page == max_lines - 1
        '         repeat max_lines scroll_list_forward()

        '     selected_line_on_page = num_visible_dirs - 1
        '     select_line(selected_line_on_page)
        '     print_stats()
        ' }
    END SUB

    SUB key_page_up() 
        debug.say("p-up-HAS-BUG")
        '--- BUG!  Scroll and do page up-dn
        ' line_color(selected_line_on_page, theme.TXT_NORMAL)
        ' if selected_line_on_page==0
        '     repeat max_lines scroll_list_backward()

        ' selected_line_on_page = 0
        ' select_line(0)
        ' print_stats() 
    END SUB

    SUB key_up() 
        IF selected_line_on_page + top_index = 0 THEN RETURN '--- already at top
        line_color(selected_line_on_page, theme.TXT_NORMAL)
        IF selected_line_on_page > 0 THEN
            current.logged = FALSE
            current = current.prevEntry
            selected_line_on_page--
        ELSEIF num_dirs > max_lines THEN
            scroll_list_backward()
        END IF

        show_new_folder_or_not_logged()
        'debug.say2("rec num:",current.rec_num)
        'debug.say2("top idx:",top_index)
    END SUB
    
    
    SUB scroll_list_backward() 
        IF top_index > 0 THEN
            top_index--
            ' scroll the displayed list down 1
            scroll_txt_down(LEFT_COL, TOP_ROW, DIR_NAME_SIZE, max_lines, iso:" "c)
            ' print new name at the top of the list
            txt.plot(LEFT_COL, TOP_ROW)
            current = current.prevEntry
            print_dir_name(selected_line_on_page)
        END IF
    END SUB
    
    SUB key_down() 
        IF selected_line_on_page + top_index + 1 = num_dirs THEN RETURN '--- already at bottom
        IF num_dirs > 0 THEN
            line_color(selected_line_on_page, theme.TXT_NORMAL)
            IF selected_line_on_page < num_visible_dirs - 1 THEN
                current.logged = FALSE
                selected_line_on_page++ 
                current = current.nextEntry
            ELSEIF num_dirs > max_lines THEN
                scroll_list_forward()
            END IF
            show_new_folder_or_not_logged()    
        END IF
        'debug.say2("rec num:",current.rec_num)
        'debug.say2("top idx:",top_index)
    END SUB

    SUB show_new_folder_or_not_logged() 
        'debug.say2(current.name,current.rec_num)
        line_color(selected_line_on_page, theme.ROW_HILIGHT)
        IF current.rec_num = 1 THEN '--- ONLY read ROOT?
            main.read_files(diskio.drivenumber, files_folders.filter_files, "/")
            files_cache.print_stats()
        ELSE
            files_cache.show_not_logged()
        END IF
        print_stats() '-- dir stats
    END SUB

    SUB scroll_list_forward() 
        IF top_index + max_lines < num_dirs THEN
            top_index++
            ' scroll the displayed list up 1
            scroll_txt_up(LEFT_COL, TOP_ROW, DIR_NAME_SIZE, max_lines, iso:" "c)
            ' print new name at the bottom of the list
            txt.plot(LEFT_COL, TOP_ROW + max_lines - 1)
            current = current.nextEntry
            print_dir_name(selected_line_on_page)
        END IF
     
    END SUB
    
    SUB scroll_txt_down(col AS UBYTE, row AS UBYTE, width AS UBYTE, height AS UBYTE, fillchar AS UBYTE) 
        ALIAS y = main.y
        ALIAS x = main.x
        FOR y = row + height - 1 DOWNTO row + 1
            FOR x = col TO col + width - 1
                txt.setchr(x, y, txt.getchr(x, y - 1))
            NEXT
        NEXT
        FOR x = col TO col + width - 1
            txt.setchr(x, row, fillchar)
        NEXT
    END SUB

    
    SUB scroll_txt_up(col AS UBYTE, row AS UBYTE, width AS UBYTE, height AS UBYTE, fillchar AS UBYTE) 
        ALIAS y = main.y
        ALIAS x = main.x
        FOR y = row TO row + height - 2
            FOR x = col TO col + width - 1
                txt.setchr(x, y, txt.getchr(x, y + 1))
            NEXT
        NEXT
        y = row + height - 1
        FOR x = col TO col + width - 1
            txt.setchr(x, y, fillchar)
        NEXT
    END SUB

    SUB draw_dirs_2_scrn()
        ALIAS i = main.i
        ALIAS str_clear = main.g_tmp_str_buffer1

        txt.color2(theme.TXT_NORMAL BITAND 15, theme.TXT_NORMAL>>4)
        num_visible_dirs = min(max_lines, num_dirs)
        'debug.say2("num dir",num_dirs)

        '--- clear panel/page
        VOID strings.copy(" "*DIR_NAME_SIZE,str_clear)
        FOR i = 0 TO max_lines
            helpers.print_strXY2(LEFT_COL,TOP_ROW + i,str_clear) 
        NEXT
        ' IF num_dirs == 0 {
        '     helpers.print_strXY2(LEFT_COL,TOP_ROW + 1,iso:"No Directories")
        '     RETURN
        ' }

        '^^Entry current = head
        current = head
        FOR i = 0 TO num_visible_dirs - 1
            print_dir_name(i)   
            current = current.nextEntry
        NEXT

        current = head '--- reset TO top
        line_color(0,theme.ROW_HILIGHT)
        selected_line_on_page = 0
    END SUB

    SUB print_dir_name(row AS UBYTE) 
        '^^Entry current is the pointer to the linked list
        ALIAS dir_name = main.g_tmp_str_buffer3
        VOID strings.copy(pretty_line(current.name, current.is_expanded), dir_name)
        helpers.print_strXY2(LEFT_COL + (current.level * LEVEL_SIZE), TOP_ROW + row, dir_name)
    END SUB

    FUNCTION pretty_line(line AS STRING, is_expanded AS BOOL) AS STRING
        '--- make dir name pretty
        ALIAS pretty_str = main.g_tmp_str_buffer2 
        ALIAS tmp_str9   = main.g_tmp_str_buffer1 
        'chr_tleft
        IF current.rec_num = 1 THEN '--- ROOT
            strings_ext.concat_strings(cp437:"", line, tmp_str9)
        ELSEIF is_expanded THEN
            strings_ext.concat_strings(cp437:" ├─", line, tmp_str9)
        ELSE
            strings_ext.concat_strings(cp437:"+├─", line, tmp_str9)
        END IF
        strings_ext.pad_right(tmp_str9, pretty_str, " "c, DIR_NAME_SIZE) 
        RETURN pretty_str
    END FUNCTION

    ' SUB set_ram_bank()
    '     sys.push(cx16.getrambank())
    '     cx16.rambank(arena_dirs.MEM_BANK62)
    ' END SUB
    ' SUB restore_ram_bank()
    '     cx16.rambank(sys.pop())
    ' END SUB

    SUB set_focus() 
        line_color(selected_line_on_page, theme.ROW_HILIGHT)
    END SUB

    SUB lost_focus() 
        line_color(selected_line_on_page, theme.TXT_NORMAL)
    END SUB

    SUB line_color(line AS UBYTE, colors AS UBYTE) 
        ALIAS charpos = main.i
        ALIAS start_col = main.j
        cx16.r1L = line + TOP_ROW
        start_col = 2 + LEFT_COL + (current.level * LEVEL_SIZE)
        IF current.rec_num = 1 THEN start_col = LEFT_COL
        
        FOR charpos = start_col TO DIR_NAME_SIZE + LEFT_COL
            txt.setclr(charpos, cx16.r1L, colors)
        NEXT
    END SUB

    SUB print_stats() 
        '--- stats on folders
        ALIAS tmp  = main.g_tmp_str_buffer3
        ALIAS tmp1 = main.g_tmp_str_buffer2

        VOID strings.copy(current.name,tmp)
        IF NOT strings.endswith(tmp,"/") THEN strings.append(tmp,"/")
        strings_ext.concat_strings(tmp,files_folders.filter_dir,tmp1)
        helpers.print_strXY(6,3," "*15,theme.TXT_NORMAL,FALSE) 
        helpers.print_strXY(6,3,tmp1,theme.TXT_NORMAL,FALSE)
    END SUB

    FUNCTION create(name AS STRING, level AS UBYTE) AS ^^Entry
        DIM new_record AS ^^Entry = arena_dirs.alloc(SIZEOF(Entry))
        DIM name_copy AS ^^UBYTE  = arena_dirs.alloc(strings.length(name) + 1)
        VOID strings.copy(name, name_copy)

        num_dirs++

        new_record.name = name_copy
        new_record.is_expanded = FALSE
        new_record.level = level
        new_record.has_children = FALSE
        new_record.visible = TRUE
        new_record.logged = FALSE
        new_record.nextEntry = 0
        new_record.prevEntry = 0
        new_record.rec_num = num_dirs

        RETURN new_record
    END FUNCTION

    SUB add(name AS STRING, level AS UBYTE) 
        '--- Create new entry
        DIM new_record AS ^^Entry = create(name, level)

        '--- Add to the end of the doubly linked list
        IF head = 0 THEN  '--- First entry
            head = new_record
            tail = new_record
        ELSE        '--- Add to the end
            tail.nextEntry = new_record
            new_record.prevEntry = tail
            tail = new_record
        END IF
    END SUB

    SUB insert(name AS STRING, level AS UBYTE, previous_entry AS ^^Entry, as_child AS BOOL) 

        DIM new_record AS ^^Entry = create(name, level)

        '== Configure new record as child of previous entry
        IF as_child THEN
            previous_entry.has_children = TRUE
            new_record.level = previous_entry.level + 1

        END IF

        '== Link new record to surrounding records
        new_record.nextEntry = previous_entry.nextEntry
        previous_entry.nextEntry = new_record
        new_record.prevEntry = previous_entry
        new_record.nextEntry.prevEntry = new_record
    END SUB
END MODULE


MODULE arena_dirs
    ' Simple arena allocator
    CONST MEM_BANK61 AS UBYTE = 61
    'DIM buffer AS UWORD = $a000
    DIM buffer AS UWORD = memory("a_dirs", 3200, 0)
    DIM nextEntry AS UWORD = buffer

    FUNCTION alloc(size AS UBYTE) AS UWORD
        DEFER nextEntry += size
        RETURN nextEntry
    END FUNCTION

    SUB free_all() 
        ' cannot free individual allocations only the whole arena at once
        ' UNTESTED!!! - assuming this resets the pointer to the top
        nextEntry = buffer
    END SUB
END MODULE
