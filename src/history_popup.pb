'==============================================================================
'---   
'---   history_prompt.pb,  generic popup for line editor history
'---   
'==============================================================================
'---   
'==============================================================================

'IMPORT dos_files
'IMPORT key_const
IMPORT screen
IMPORT strings
IMPORT helpers
IMPORT stree
IMPORT key_const
IMPORT diskio

MODULE prompt_history

    ALIAS i = main.i
    ALIAS j = main.j

    CONST FILE_FILESPEC AS UBYTE = 1
    CONST NOTHING AS UBYTE = 0

    SUB popup(what AS UBYTE)

        ALIAS fname = main.g_tmp_str_buffer1
        screen.store()

        '--- draw cool box
        helpers.draw_box(10, 13, 36, 43, theme.BOX2)
        helpers.clear_section(10+1, 13+1, 36-2, 43-2, theme.BOX2) 
        VOID strings.copy("", fname)

        '--- load appropriate history and enter interactive loop
        SELECT CASE what
            CASE FILE_FILESPEC 
                VOID strings.copy(iso:"/src/hist/f-f.hst", fname)
            CASE NOTHING
                RETURN
        END SELECT

        DIM keycode AS UBYTE
        IF strings.length(fname) = 0 THEN RETURN
        IF history_menu.read_file_print_2_scrn(fname) = 0 THEN RETURN 
        
        '--- start the menu
        REPEAT
            keycode = cbm.GETIN2()
            IF keycode = 0 THEN CONTINUE
            
            IF keycode = keys.UP_ARROW_PRESSED THEN
                history_menu.select_up()  
                CONTINUE
            END IF
            IF keycode = keys.DN_ARROW_PRESSED THEN
                history_menu.select_down() 
                CONTINUE
            END IF

            SELECT CASE keycode
                CASE keys.ESC '--- cancel, don't change input buffer
                    BREAK
                CASE keys.CR  '--- accept selection: copy into line editor buffer
                    'DIM sel AS STRING = "?"*55 
                    'history_menu.get_selected()
                    'VOID strings.copy(history_menu.tmp_str, main.g_tmp_str_buffer3)
                    BREAK
                CASE ELSE
                    '--- ignore other keys
            END SELECT
        END REPEAT

        screen.restore()
    END SUB




    ' SUB append_2_hist_file(fname AS STRING)
    '     IF NOT diskio.exists(fname) THEN
    '         create_file(fname)
    '     END IF
    ' END SUB

    ' SUB create_file(fname AS STRING)
    '     ALIAS str_tmp = main.g_tmp_str_buffer2
    '     VOID strings.copy(fname,str_tmp)  
              
    ' END SUB



END MODULE


MODULE history_menu

    CONST ROW_START AS UBYTE = 50
    CONST COL_START AS UBYTE = 12
    CONST ROW_WIDTH AS UBYTE = 30

    DIM num_entries, selected_index AS BYTE = 0
    DIM txt_buffer AS STRING = "?"*70
     
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
      
        REPEAT
            VOID, VOID = diskio.f_readline(&txt_buffer)
            IF cbm.READST() & $40 <> 0 THEN '--- EOF
                BREAK
            END IF
            
            IF strings.startswith(txt_buffer, "#") THEN CONTINUE '--- comment, skip
            IF strings.length(txt_buffer) = 0 THEN CONTINUE      '--- fixes Win vs Linux LF's i think
            
            helpers.print_strXY(COL_START, ROW_START - num_entries AS UBYTE, txt_buffer, theme.BOX2, FALSE)
            num_entries++
        
        END REPEAT
        diskio.f_close()

        '--- hilight 1st one
        selected_index = 0
        hi_unhilight_row(TRUE)
        'debug.say2("init", selected_index)
        RETURN num_entries AS UBYTE

    END FUNCTION


    ' '--- Load entry from screen row into tmp_str
    ' SUB read_item_from_scrn(index AS UBYTE, col AS UBYTE)
    '     DIM row AS UBYTE = STORAGE_START_ROW + index
    '     DIM c AS UBYTE = 0
    '     DIM ch AS UBYTE
        
    '     '--- Initialize tmp_str to empty
    '     tmp_str[0] = 0
        
    '     '--- Read characters until null terminator or end of buffer
    '     WHILE c < ENTRY_SIZE - 1
    '         ch = txt.getchr(col + c, row)
    '         IF ch = 0 THEN BREAK
    '         tmp_str[c] = ch
    '         c++
    '     WEND
    '     tmp_str[c] = 0  '--- null terminate at correct position
    ' END SUB


    ' '--- Get currently selected entry string
    ' SUB get_selected() 'AS STRING
    '     IF selected_index < num_entries THEN
    '         read_item_from_scrn(selected_index, 0) ' read into tmp_str
    '     END IF
    '     VOID strings.copy("", tmp_str)
    ' END SUB


END MODULE


