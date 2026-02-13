'==============================================================================
'---   
'---   history_prompt.pb,  generic popup for line editor history
'---   
'==============================================================================
'---   
'==============================================================================

IMPORT dos_files
IMPORT screen
IMPORT strings
IMPORT helpers
IMPORT stree
IMPORT key_const
IMPORT diskio
IMPORT line_editor
IMPORT strings_ext

MODULE prompt_history

    DIM hist_path AS STRING = iso:"/src/hist/" 'TODO !! need to calc on startup  

    DIM str_tmp01 AS STRING = "?"*70
    ' DIM str_tmp02 AS STRING = "?"*70
    ' DIM hist_path AS STRING = "?"*70
    ALIAS fname = main.g_tmp_str_buffer1

    CONST FILE_FILESPEC AS UBYTE = 1
    CONST FILE_RENAME AS UBYTE = 2
    CONST NOTHING AS UBYTE = 0

    FUNCTION popup(what AS UBYTE) AS STRING
        
        get_fname(what) '--- set the fname var  
        IF strings.length(fname) = 0 THEN RETURN ""
        IF NOT diskio.exists(fname) THEN  RETURN "" ' create new file, should never happen...   TODO
        
        screen.store()
        DEFER screen.restore()

        '--- draw cool box ------------------------------------- TODO, refactor
        CONST bLEFT AS UBYTE = 12
        CONST bWIDTH AS UBYTE = 66
        CONST bTOP_ROW AS UBYTE = 13
        CONST bHEIGHT AS UBYTE = 43
        helpers.draw_box(bLEFT, bTOP_ROW, bWIDTH,bHEIGHT, theme.BOX2)
        helpers.clear_section(bLEFT+1, bTOP_ROW+1, bWIDTH-2, bHEIGHT-2,theme.BOX2) 
        helpers.draw_horiz_line(bLEFT, bTOP_ROW+bHEIGHT-5, bWIDTH,theme.BOX2)
        helpers.plot_charXY(bLEFT,bTOP_ROW+bHEIGHT-5,helpers.chr_tleft,theme.BOX2)
        helpers.plot_charXY(bLEFT+bWIDTH-1,bTOP_ROW+bHEIGHT-5,helpers.chr_tright,theme.BOX2)
        helpers.clear_section(bLEFT+1,bTOP_ROW+bHEIGHT-4,bWIDTH-2,3,theme.TXT_NORMAL)
        helpers.print_strXY(bLEFT+24,bTOP_ROW+bHEIGHT-3,iso:"Select  ESC Cancel",theme.MENU_NORMAL,FALSE)
        prompts.draw_icons(0, 34,bTOP_ROW+bHEIGHT-3)
        menus.highlight_menu_keys([44,45,46],2,bTOP_ROW+bHEIGHT-3,theme.MENU_BRIGHT)
        '--------------------------------------------------------
        
        'debug.say("start" ) ' remember screen restore
        IF history_menu.read_file_print_2_scrn(fname) = 0 THEN 
            'debug.say("fail" ) ' remember screen restore
            RETURN ""
        END IF
        'debug.say("end" ) ' remember screen restore

        '--- start the menu
        ALIAS ret_txt_buffer = str_tmp01
        'ALIAS keycode = main.i
        DIM keycode AS UBYTE
        REPEAT
            keycode = cbm.GETIN2()
            IF keycode = 0 THEN CONTINUE
            
            SELECT CASE keycode
                CASE keys.DN_ARROW_PRESSED 
                    history_menu.select_down()  

                CASE keys.UP_ARROW_PRESSED
                    history_menu.select_up()  

                CASE keys.ESC '--- bye!
                    'debug.say("esc" ) ' remember screen restore
                    ret_txt_buffer[0] = 0 
                    BREAK

                CASE keys.CR  '--- accept selection
                    'debug.say("cr" ) ' remember screen restore
                    history_menu.read_item_from_scrn() ' copied into ret_txt_buffer
                    'history_append.add_2_hist_file(prompt_history.FILE_FILESPEC,ret_txt_buffer) ' move selection to top of HST list
                    BREAK
            END SELECT
        END REPEAT

        main.clear_kb()
        'sys.wait(120) ' debug stuff
        RETURN ret_txt_buffer
                 
    END FUNCTION



    SUB get_fname(what AS UBYTE)
        'DIM p AS STRING = "?"*90
        ALIAS p = main.g_tmp_str_buffer2
        VOID strings.copy(DOS.join_path_file(hist_path,iso:"*.hst"),p) 'TODO, hist path
        DIM find_this AS STRING = iso:"*"
        fname[0] = 0

        '--- set correct file name
        SELECT CASE what
            CASE FILE_FILESPEC 
                strings_ext.replace(p,find_this,iso:"f-f",fname)
            CASE FILE_RENAME 
                strings_ext.replace(p,find_this,iso:"f-r",fname)
            CASE ELSE
                RETURN
        END SELECT

    END SUB

END MODULE


'======================================================================


MODULE history_append

    ALIAS fname = main.g_tmp_str_buffer1
    
    TYPE Entry
        nextEntry AS ^^Entry          ' Next entry in the list
        prevEntry AS ^^Entry          ' Previous entry in the list    - TODO, prevEntry should be removed?
        name AS STRING                ' Name
    END TYPE

    DIM head AS ^^Entry = 0           ' Head of the doubly linked list
    DIM tail AS ^^Entry = 0           ' Tail of the doubly linked list - TODO, tail should be removed?
    DIM current AS ^^Entry


    SUB add_2_hist_file(what AS UBYTE, new_str AS STRING)
        
        'debug.say(new_str)
        'sys.wait(400)
        prompt_history.get_fname(what) '--- saves filename in var 'fname'
        IF strings.length(fname) = 0 THEN RETURN
        
        DIM num_entries AS UBYTE = 0
        DIM txt_buffer AS STRING = "?"*80

        'debug.say("add_2_hist-1")
        IF NOT diskio.f_open(fname) THEN RETURN '--- open file

        '--- new RAMBANK for string and stuff
        sys.push(cx16.getrambank())
        cx16.rambank(mem_banks.BANK60)
        arena_strings.free_all()
        DEFER cx16.rambank(sys.pop())

        'debug.say("add_2_hist-2222")
        REPEAT '--- read old hist file and save to memory

            ' --- works fine with CRLF files
            ' --- if CR or LF only then it skips the last entry
            ' --- BUT... only tested on HOSTFS
            ' ---
            VOID, VOID = diskio.f_readline(&txt_buffer)
            IF cbm.READST() & $40 <> 0 THEN '--- EOF
                BREAK
            END IF
            
            IF strings.startswith(txt_buffer, "#") THEN CONTINUE '--- comment, skip
            IF strings.length(txt_buffer) = 0 THEN CONTINUE      '--- fixes Win vs Linux LF's i think, blank lines where coming in
            num_entries++
            add(txt_buffer)
    
        END REPEAT
        diskio.f_close() 


        'debug.say2("add_2_hist-3:",num_entries) : sys.wait(400)
        DIM fname_bak AS STRING = "?"*80  
        VOID strings.copy(fname,fname_bak)                        '--- back up current hist file
        VOID strings.append(fname_bak,".bak")
        diskio.delete(fname_bak)
        diskio.rename(fname,fname_bak)

        
        
        DIM CRLF AS STRING = "  " : CRLF[0] = $0d : CRLF[1] = $0a  '--- write new hist file with new entry
        'DIM CR AS UWORD = $0d

        DIM num AS UBYTE = 1
        VOID diskio.f_open_w(fname)                             '--- open, create file
        VOID diskio.f_write(new_str, strings.length(new_str))   '--- write new entry at top
        VOID diskio.f_write(CRLF, 2)                            '--- write EOL
        current = head '--- top

        REPEAT 
            IF strings.compare_nocase_iso(new_str,current.name) = 0 THEN '--- see if entry is dupe
                current = current.nextEntry
                num++
                CONTINUE
            END IF
            VOID diskio.f_write(current.name, strings.length(current.name))
            VOID diskio.f_write(CRLF, 2) '--- write EOL
            current = current.nextEntry
            num++
            IF num > 28 OR num > num_entries THEN BREAK '--- 25 history items is max
        END REPEAT
        
        'debug.say2("num:",num) : sys.wait(400)
        diskio.f_close_w() 
         
    END SUB



    '=========================

    FUNCTION create(name AS STRING) AS ^^Entry
        DIM new_record AS ^^Entry = arena_strings.alloc(SIZEOF(Entry))
        DIM name_copy AS ^^UBYTE  = arena_strings.alloc(strings.length(name) + 1)
        VOID strings.copy(name, name_copy)
        new_record.name = name_copy
        RETURN new_record
    END FUNCTION

    SUB add(name AS STRING) 
        '--- Create new entry
        DIM new_record AS ^^Entry = create(name)

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
    

END MODULE

MODULE arena_strings
    ' Simple arena allocator, refactored
    DIM buffer AS UWORD = $A000
    'DIM buffer AS UWORD = memory("a_strs", 3200, 0)
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

'======================================================================

MODULE history_menu

    CONST ROW_START AS UBYTE = 50
    CONST COL_START AS UBYTE = 14 
    CONST ROW_WIDTH AS UBYTE = 76 - COL_START 
    DIM num_entries, selected_index AS BYTE = 0
    ALIAS txt_buffer = prompt_history.str_tmp01

    SUB select_up() 
        hi_unhilight_row(FALSE)
        selected_index++
        IF selected_index >= num_entries THEN selected_index = 0
        hi_unhilight_row(TRUE)
    END SUB

    SUB select_down() 
        hi_unhilight_row(FALSE)
        selected_index--
        IF selected_index = -1 THEN selected_index = num_entries - 1 
        hi_unhilight_row(TRUE)
    END SUB

    SUB hi_unhilight_row(hi AS BOOL)
        IF hi THEN 
            helpers.clr_section(COL_START, ROW_START - selected_index AS UBYTE, ROW_WIDTH, 1, theme.TXT_NORMAL)
        ELSE
            helpers.clr_section(COL_START, ROW_START - selected_index AS UBYTE, ROW_WIDTH, 1, theme.BOX2)
        END IF
    END SUB
    

    FUNCTION read_file_print_2_scrn(filename AS STRING) AS UBYTE
        
        num_entries = 0
        IF NOT diskio.f_open(filename) THEN RETURN 0

        '--- read in hist file to screen memory
        REPEAT
            ' --- works fine with CRLF files
            ' --- if CR or LF only then it skips the last entry
            ' --- BUT... only tested on HOSTFS
            ' ---
            VOID, VOID = diskio.f_readline(txt_buffer)
            IF cbm.READST() & $40 <> 0 THEN '--- EOF
                BREAK
            END IF
            
            IF strings.startswith(txt_buffer, "#") THEN CONTINUE '--- comment, skip
            IF strings.length(txt_buffer) = 0 THEN CONTINUE      '--- fixes Win vs Linux LF's i think, blank lines where coming in
            
            helpers.print_strXY(COL_START, ROW_START - num_entries AS UBYTE, txt_buffer, theme.BOX2, FALSE)
            num_entries++
        
        END REPEAT
        diskio.f_close()

        '--- hilight 1st one
        selected_index = 0
        hi_unhilight_row(TRUE)
        txt_buffer[0] = 0 
        'debug.say("start300" )
        RETURN num_entries AS UBYTE

    END FUNCTION


    '--- Load entry from screen row into tmp_str
    SUB read_item_from_scrn()
        DIM row AS UBYTE = ROW_START - selected_index AS UBYTE
        DIM ch,c AS UBYTE = 0
        
        txt_buffer[0] = 0           '--- Initialize txt_buffer to empty
        
        WHILE c < ROW_WIDTH - 1     '--- Read characters from screen mem
            ch = txt.getchr(COL_START + c, row)
            IF ch = 0 THEN BREAK
            txt_buffer[c] = ch
            c++
        WEND
        txt_buffer[c] = 0           '--- end of string Char
        strings.strip(txt_buffer)   '--- Just clean up
        'debug.say(txt_buffer)
    END SUB



END MODULE


