'==============================================================================
'---   
'---   Double linked list of files
'---   
'==============================================================================
'---   
'==============================================================================

MODULE files_cache
    TYPE Entry
        nextEntry AS PTR Entry           ' nextEntry entry in the list
        prevEntry AS PTR Entry           ' Previous entry in the list
        name AS STRING               ' Name (key)
        is_tagged AS BOOL
        blocks AS UWORD           ' store blocks OR kb here?
        rec_num AS UBYTE
    END TYPE

    DIM head AS PTR Entry = 0           ' Head of the doubly linked list
    DIM tail AS PTR Entry = 0           ' Tail of the doubly linked list
    'DIM page_top AS PTR Entry = 0       ' Tail of the doubly linked list

    DIM num_files, num_tagged AS UBYTE = 0        ' Number of entries

    ALIAS FILE_NAME_SIZE = files_folders.FILE_MAX_LEN
    CONST NOT_TAGGED AS BOOL = FALSE
    CONST LEFT_COL AS UBYTE = 32
    CONST TOP_ROW AS UBYTE = 6
    DIM TAG_CHAR AS   STRING = cp437:"♦"

    'txt.print_lit(cp437:"≈ IBM Pc ≈ ÇüéâäàåçêëèïîìÄ ░▒▓│┤╡╢╖╕╣║╗╝╜╛┐ ☺☻♥♦♣♠•◘○◙♂♀♪♫☼ ►◄↕‼¶§▬↨↑↓→←∟↔▲▼")
    
    '--- vars FOR movement
    DIM top_index AS UBYTE = 0
    DIM selected_line_on_page, num_visible_files AS UBYTE
    DIM max_lines AS UBYTE = txt.height() - 12

    DIM current AS PTR Entry
    DIM item_tmp_ptr AS PTR Entry

    SUB init_clear()
        helpers.print_strXY(LEFT_COL,TOP_ROW,cp437:"Reading...",theme.TXT_NORMAL,FALSE)
        num_files = num_tagged = top_index = selected_line_on_page = num_visible_files = 0         ' Number of entries
    END SUB

    
    SUB key_page_down()
        debug.say("p-down-HAS-BUG")
        '--- BUG!  Scroll and do page up-dn
        ' IF num_files > 0 THEN
        '     ' nextEntry page of lines
        '     unselect_line(selected_line_on_page)
        '     IF selected_line_on_page = max_lines - 1 THEN
        '         REPEAT max_lines scroll_list_forward() END REPEAT
        '     END IF
        '     selected_line_on_page = num_visible_files - 1
        '     select_line(selected_line_on_page)
        '     print_stats()
        ' END IF
    END SUB

    SUB key_page_up()
        debug.say("p-up-HAS-BUG")
        '--- BUG!  Scroll and do page up-dn
        ' line_color(selected_line_on_page, theme.TXT_NORMAL)
        ' IF selected_line_on_page = 0 THEN
        '     REPEAT max_lines scroll_list_backward() END REPEAT
        ' END IF
        ' selected_line_on_page = 0
        ' select_line(0)
        ' print_stats() 
    END SUB


    SUB key_up()
        line_color(selected_line_on_page, theme.TXT_NORMAL)
        IF selected_line_on_page > 0 THEN
            current = current.prevEntry
            selected_line_on_page--
        ELSEIF num_files > max_lines THEN
            scroll_list_backward()
        END IF

        line_color(selected_line_on_page, theme.ROW_HILIGHT)
        print_stats()
        'debug.say2("rec num:",current.rec_num)
        'debug.say2("top idx:",top_index)
    END SUB
    
    
    SUB scroll_list_backward()
        IF top_index > 0 THEN
            top_index--
            ' scroll the displayed list down 1
            scroll_txt_down(LEFT_COL, TOP_ROW, FILE_NAME_SIZE, max_lines, iso:" "c)
            ' print new name at the top of the list
            txt.plot(LEFT_COL, TOP_ROW)
            current = current.prevEntry
            print_filename(selected_line_on_page)
        END IF
    END SUB
    

    SUB key_down()
        IF num_files > 0 THEN
            line_color(selected_line_on_page, theme.TXT_NORMAL)
            IF selected_line_on_page < num_visible_files - 1 THEN
                selected_line_on_page++ 
                current = current.nextEntry
            ELSEIF num_files > max_lines THEN
                scroll_list_forward()
            END IF
                
            line_color(selected_line_on_page, theme.ROW_HILIGHT)
            print_stats()
        END IF
        'debug.say2("rec num:",current.rec_num)
        'debug.say2("top idx:",top_index)
    END SUB


    SUB scroll_list_forward()
        IF top_index + max_lines < num_files THEN
            top_index++
            ' scroll the displayed list up 1
            scroll_txt_up(LEFT_COL,TOP_ROW,FILE_NAME_SIZE,max_lines,iso:" "c)
            ' print new name at the bottom of the list
            txt.plot(LEFT_COL,TOP_ROW + max_lines - 1)
            current = current.nextEntry
            print_filename(selected_line_on_page)
        END IF
    END SUB
    

    SUB scroll_txt_down(col AS UBYTE, row AS UBYTE, width AS UBYTE, height AS UBYTE, fillchar AS UBYTE)
        ALIAS y = main.y
        ALIAS x = main.x
        FOR y = row+height-1 TO row+1 STEP -1
            FOR x = col TO col+width-1
                txt.setchr(x,y, txt.getchr(x, y-1))
            NEXT
        NEXT
        FOR x = col TO col+width-1
            txt.setchr(x,row, fillchar)
        NEXT
    END SUB

    
    SUB scroll_txt_up(col AS UBYTE, row AS UBYTE, width AS UBYTE, height AS UBYTE, fillchar AS UBYTE)
        ALIAS y = main.y
        ALIAS x = main.x
        FOR y = row TO row+height-2
            FOR x = col TO col+width-1
                txt.setchr(x,y, txt.getchr(x, y+1))
            NEXT
        NEXT
        y = row+height-1
        FOR x = col TO col+width-1
            txt.setchr(x,y, fillchar)
        NEXT
    END SUB


    SUB show_not_logged()
        clear_panel()
        helpers.print_strXY(LEFT_COL,TOP_ROW,cp437:"Not Logged",theme.TXT_NORMAL,FALSE)
        files_folders.clear_files()
        print_stats()
    END SUB

    SUB clear_panel()
        '--- clear panel/page
        ALIAS i = main.i
        ALIAS str_clear = main.g_tmp_str_buffer1
        VOID strings.copy(" " * files_folders.FILE_MAX_LEN_CLEAR, str_clear)
        FOR i = 0 TO max_lines
            helpers.print_strXY2(LEFT_COL,TOP_ROW + i,str_clear) 
        NEXT
    END SUB

    SUB draw_files_2_scrn(select_this_line AS UBYTE)
        ALIAS i = main.i
        
        txt.color2(theme.TXT_NORMAL BITAND 15, theme.TXT_NORMAL SHR 4)
        num_visible_files = min(max_lines, num_files)

        clear_panel()
        IF num_files = 0 THEN
            helpers.print_strXY2(LEFT_COL,TOP_ROW, iso:"No Files")
            RETURN
        END IF

        'current = head
        current = find_by_recnum(top_index+1)
        item_tmp_ptr = current
        FOR i = 0 TO num_visible_files - 1
            print_filename(i)   
            current = current.nextEntry
        NEXT
        current = item_tmp_ptr '--- reset to top visible line
        line_color(select_this_line,theme.ROW_HILIGHT)
        selected_line_on_page = select_this_line
    END SUB


    SUB print_filename(row AS UBYTE)
        'PTR Entry current is the pointer to the linked list
        ALIAS filename = main.g_tmp_str_buffer3
        VOID strings.copy(pretty_line(current.name,current.is_tagged),filename)
        helpers.print_strXY2(LEFT_COL,TOP_ROW + row,filename)
    END SUB


    FUNCTION pretty_line(line AS STRING, tagged AS BOOL) AS STRING
        '--- make file name pretty
        ALIAS pretty_str = main.g_tmp_str_buffer2 
        ALIAS tmp_str9   = main.g_tmp_str_buffer1 
        IF tagged THEN
            strings_ext.concat_strings(TAG_CHAR,line,tmp_str9)
        ELSE
            strings_ext.concat_strings(cp437:" ",line,tmp_str9)
        END IF
        strings_ext.pad_right(tmp_str9, pretty_str, " "c, FILE_NAME_SIZE) 
        RETURN pretty_str
    END FUNCTION


    SUB set_focus()  '--- called when changing from FILES - DIR panels
        IF num_files = 0 THEN RETURN
        line_color(selected_line_on_page, theme.ROW_HILIGHT)
    END SUB

    SUB lost_focus()  '--- called when changing from FILES - DIR panels
        IF num_files = 0 THEN RETURN
        line_color(selected_line_on_page, theme.TXT_NORMAL)
    END SUB

    SUB line_color(line AS UBYTE, colors AS UBYTE)
        ALIAS charpos = main.i
        cx16.r1L = line+TOP_ROW
        FOR charpos = LEFT_COL TO FILE_NAME_SIZE + LEFT_COL
            txt.setclr(charpos, cx16.r1L, colors)
        NEXT
    END SUB

    SUB add(name AS STRING, blocks AS UWORD)
        '--- Create new entry

        DIM new_record AS PTR Entry = arena_files.alloc(SIZEOF(Entry))
        DIM name_copy AS PTR UBYTE = arena_files.alloc(strings.length(name) + 1)
        VOID strings.copy(name, name_copy)

        num_files++

        new_record.name = name_copy
        new_record.is_tagged = FALSE
        new_record.blocks = blocks
        new_record.nextEntry = 0
        new_record.prevEntry = 0
        new_record.rec_num = num_files 

        '--- Add to the end of the doubly linked list
        IF head = 0 THEN '--- First entry
            head = new_record
            tail = new_record
        ELSE       '--- Add to the end
            tail.nextEntry = new_record
            new_record.prevEntry = tail
            tail = new_record
        END IF
    END SUB
    
    SUB tag_file(line_num AS UBYTE, tag AS BOOL)
        DEFER print_stats()
        DEFER key_down()
        IF current.is_tagged = tag THEN
            RETURN '--- file already tagged or untagged
        END IF
        current.is_tagged = tag 
        IF tag THEN num_tagged++ ELSE num_tagged--  '--- inc / decr       
        print_filename(line_num)
    END SUB


    SUB tag_all(tag AS BOOL)
        
        ALIAS ndx = main.x
        ALIAS last_selected = main.j
        ALIAS lrec = main.y
        num_tagged = IIF tag THEN num_files ELSE 0
        'DIM last_selected, lrec AS UBYTE
        
        line_color(selected_line_on_page,theme.TXT_NORMAL)
        last_selected = selected_line_on_page
        lrec = current.rec_num

        '--- tag everything
        current = head
        FOR ndx = 0 TO files_cache.num_files - 1
            current.is_tagged = tag
            current = current.nextEntry
        NEXT
        draw_files_2_scrn(last_selected)
        print_stats()
        current = find_by_recnum(lrec)

        '=== debug crap!
        ' DIM i2 AS STRING = "?"*24
        ' DIM i1 AS STRING = "?"*24
        ' strings_ext.concat_strings("rec1:",conv.str_ub(lrec),i1)
        ' strings_ext.concat_strings("rec2:",conv.str_ub(current.rec_num),i2)
        ' helpers.print_strXY(2,50,"                     ",theme.TXT_NORMAL,FALSE)
        ' helpers.print_strXY(2,51,"                     ",theme.TXT_NORMAL,FALSE)
        ' helpers.print_strXY(2,50,i1,theme.TXT_NORMAL,FALSE)
        ' helpers.print_strXY(2,51,i2,theme.TXT_NORMAL,FALSE)
    END SUB


    FUNCTION find_by_recnum(rec_num AS UBYTE) AS PTR Entry
        DIM item AS PTR Entry = head
        WHILE item <> 0
            IF item.rec_num = rec_num THEN
                RETURN item
            END IF
            item = item.nextEntry
        WEND
        RETURN 0  ' Not found - should not happen
    END FUNCTION

    SUB print_stats()
        ' TODO needs refactor
        ALIAS i = main.i
        ALIAS real_num = main.j
        'ALIAS x = main.x
        'i = txt.height() - 6
        i = 3
        helpers.print_strXY(51,i,cp437:"[File:    Of:    Tagged:    ]",theme.BOXES,FALSE)
        IF num_files = 0 THEN
            helpers.print_strXY(57,i,conv.str_ub(0),theme.TXT_NORMAL,FALSE)
        ELSE 
            helpers.print_strXY(57,i,conv.str_ub(selected_line_on_page + 1 + top_index),theme.TXT_NORMAL,FALSE) 
        END IF
        helpers.print_strXY(64,i,conv.str_ub(num_files),theme.TXT_NORMAL,FALSE)
        helpers.print_strXY(75,i,conv.str_ub(num_tagged),theme.TXT_NORMAL,FALSE)

        ' DIM i2 AS STRING = "?"*24
        ' DIM i1 AS STRING = "?"*24
        ' strings_ext.concat_strings("top ndx:",conv.str_ub(top_index),i1)
        ' strings_ext.concat_strings("rec num:",conv.str_ub(current.rec_num),i2)
        ' helpers.print_strXY(52,50,"                     ",theme.TXT_NORMAL,FALSE)
        ' helpers.print_strXY(52,51,"                     ",theme.TXT_NORMAL,FALSE)
        ' helpers.print_strXY(52,50,i1,theme.TXT_NORMAL,FALSE)
        ' helpers.print_strXY(52,51,i2,theme.TXT_NORMAL,FALSE)

    END SUB


END MODULE

MODULE arena_files
    ' Simple arena allocator
    DIM buffer AS UWORD = memory("a_files", 6400, 0)
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



    ' SUB print_forward()
    '     DIM current AS PTR Entry = head
    '     WHILE current <> 0
    '         txt.print("- ")
    '         txt.print(current.name)
    '         txt.print(" (dir:")
    '         txt.print_bool(current.is_dir)
    '         txt.print(", ")
    '         txt.print(" (tagged:")
    '         txt.print_bool(current.is_tagged)
    '         txt.print(")\n")
    '         current = current.nextEntry
    '     WEND
    '     txt.print("Total entries: ")
    '     txt.print_uw(num_files)
    '     txt.print("\n")
    ' END SUB

    ' SUB print_backward()
    '     DIM current AS PTR Entry = tail
    '     WHILE current <> 0
    '         txt.print("- ")
    '         txt.print(current.name)
    '         txt.print(" (dir:")
    '         txt.print_bool(current.is_dir)
    '         txt.print(", ")
    '         txt.print(" (is_tagged:")
    '         txt.print_bool(current.is_tagged)
    '         txt.print(")\n")
    '         current = current.prevEntry
    '     WEND
    '     txt.print("Total entries: ")
    '     txt.print_uw(num_files)
    '     txt.print("\n")
    ' END SUB

    

    ' FUNCTION find_by_filename(name AS STRING) AS PTR Entry
    '     DIM current AS PTR Entry = head
    '     WHILE current <> 0
    '         IF strings.compare(current.name, name) = 0 THEN
    '             RETURN current
    '         END IF
    '         'current = current.hash_next
    '         current = current.nextEntry
    '     WEND
    '
    '     RETURN 0  ' Not found
    ' END FUNCTION

    

    ' FUNCTION remove(name AS STRING) AS BOOL
    '     ' Find the entry
    '     DIM to_remove AS PTR Entry = find(name)
    '     IF to_remove = 0 THEN
    '         RETURN FALSE  ' Not found
    '     END IF
    '
    '     ' Remove from doubly linked list
    '     IF to_remove.prevEntry <> 0 THEN
    '         to_remove.prevEntry.nextEntry = to_remove.nextEntry
    '     ELSE
    '         head = to_remove.nextEntry  ' Was the head
    '     END IF
    '
    '     IF to_remove.nextEntry <> 0 THEN
    '         to_remove.nextEntry.prevEntry = to_remove.prevEntry
    '     ELSE
    '         tail = to_remove.prevEntry  ' Was the tail
    '     END IF
    '
    '     num_files--
    '     RETURN TRUE
    ' END FUNCTION


    ' SUB movement_line(movement AS UBYTE)
    '     
    '     IF num_files = 0 THEN RETURN '--- no files
    '     '--- TODO --->  HAVE TO ADD PAGE UP/DN 
    '     SELECT CASE movement
    '         CASE MOVE_UP
    '             IF pages_index = 1 AND inner_index = 1 THEN RETURN '--- top
    '             line_color(inner_index,theme.TXT_NORMAL)
    '             inner_index--
    '             line_color(inner_index,theme.ROW_HILIGHT)
    '         CASE MOVE_DN
    '             IF pages_index * inner_index = num_files THEN 
    '                 debug.say("MOVE_DN-LAST ENTRY")
    '                 RETURN  '--- bottom
    '             END IF
    '                 
    '             IF (inner_index) = page_height THEN
    '                 scroll_txt_up(LEFT_COL,TOP_ROW,FILE_NAME_SIZE,page_height," "c)
    '                 pages_index++
    '             ELSE
    '                 'debug.say2("inner index",inner_index)
    '                 line_color(inner_index,theme.TXT_NORMAL)
    '                 inner_index++
    '                 line_color(inner_index,theme.ROW_HILIGHT)
    '             END IF
    '             
    '         CASE MOVE_PG_UP
    '         CASE MOVE_PG_DN
    '         
    '     END SELECT
    '     debug.say2("inner index",inner_index)     
    ' END SUB
    
