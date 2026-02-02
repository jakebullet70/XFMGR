'==============================================================================
'---   
'---   line_editor.pb,  single line editor with blining cursor
'---   
'==============================================================================
'---   
'==============================================================================


MODULE line_editor

    DIM CANCEL_INPUT AS STRING = "@"
    
    SUB get_txt(p_length AS UBYTE, col AS UBYTE, adj_row AS UBYTE,
            cancel_keys[] AS UBYTE, cancel_keys_len AS UBYTE,
            accept_keys[] AS UBYTE, accept_keys_len AS UBYTE,
            history_prompt_val AS UBYTE)

        '--- ESC is always cancel
        '---
        ALIAS keycode = main.x
        ALIAS i = main.i
        ALIAS j = main.j
        ALIAS break_out = main.bool_tmp
        'ALIAS current_len = main.y
        DIM current_len,ndx AS UBYTE

        '--- put the return val in this string
        ALIAS input_str_ret_val = main.g_tmp_str_buffer3
        
        break_out = FALSE
        main.clear_kb()

        '--- Initialize input_str_ret_val from text parameter
        
        ndx = strings.length(input_str_ret_val) 
        IF ndx > 0 THEN 
            helpers.print_strXY(col, txt.height() - adj_row, input_str_ret_val, theme.MENU_BRIGHT, FALSE)
        END IF
        
        txt.color2(theme.MENU_BRIGHT & 15, theme.MENU_BRIGHT >> 4)
        txt.plot(col+ndx, txt.height() - adj_row)
        'txt.plot(col+ndx-(IIF p_length <= 1 THEN 0 ELSE 1), txt.height() - adj_row)
        cx16.blink_enable(TRUE)
        
        REPEAT
            keycode = cbm.GETIN2()             
            IF keycode = 0 THEN CONTINUE
            
            'debug.say2("gt-kcode:",main.keycode_ext)
            txt.plot(col + ndx, txt.height() - adj_row)
            cx16.blink_enable(FALSE)

            '==============================================================
            FOR i = 0 TO cancel_keys_len
                IF cancel_keys[i] = keycode THEN
                    VOID strings.copy(CANCEL_INPUT, input_str_ret_val)
                    break_out = TRUE
                    BREAK '--- breaks out of this FOR loop
                END IF
            NEXT
            FOR i = 0 TO accept_keys_len
                IF accept_keys[i] = keycode THEN
                    break_out = TRUE
                    BREAK '--- breaks out of this FOR loop
                END IF
            NEXT
            '==============================================================
            IF keys.LEFT_ARROW IN main.last_keys THEN
                IF ndx > 0 THEN ndx--
                GOTO restart_get_loop
            END IF
            IF keys.RIGHT_ARROW IN main.last_keys THEN
                IF ndx < files_folders.FILE_MAX_LEN THEN ndx++
                GOTO restart_get_loop
            END IF
            IF keys.UP_ARROW IN main.last_keys THEN
                prompt_history.popup(history_prompt_val)
                GOTO restart_get_loop
            END IF
            '==============================================================
            'debug.say2("gt-kcode_ext:",main.keycode_ext)           
            'debug.say2("gt-kcode:",keycode)
            SELECT CASE main.keycode_ext
                CASE keys.END_KEY
                    'debug.say("endkey")
                    current_len = strings.length(input_str_ret_val)
                    IF current_len > 0 THEN 
                        ndx = current_len 
                    ELSE 
                        ndx = 0 
                    END IF
                    
                CASE keys.HOME
                    'debug.say("home")
                    ndx = 0
                    
                CASE keys.DELETE
                    'debug.say("delete")
                    '--- Delete character at cursor position
                    current_len = strings.length(input_str_ret_val)
                    IF ndx < current_len THEN
                        FOR i = ndx TO current_len - 1
                            input_str_ret_val[i] = input_str_ret_val[i + 1]
                        NEXT
                    END IF
                
                CASE keys.BACKSPACE
                    'debug.say("backspace")
                    '--- Delete character before cursor (to the left)
                    IF ndx > 0 THEN
                        ndx--
                        current_len = strings.length(input_str_ret_val)
                        FOR i = ndx TO current_len - 1
                            input_str_ret_val[i] = input_str_ret_val[i + 1]
                        NEXT
                    END IF

                CASE ELSE        
                    IF keycode >= 32 AND keycode < 127 THEN
                        'debug.say2("gt-kcode:",keycode)
                        current_len = strings.length(input_str_ret_val)
                        '--- Only add char if not at max length
                        IF current_len < p_length THEN
                            '--- Shift chars right to make room at ndx
                            FOR i = current_len TO ndx STEP -1
                                input_str_ret_val[i + 1] = input_str_ret_val[i]
                            NEXT
                            '--- Insert the new character
                            input_str_ret_val[ndx] = keycode
                            ndx++
                        END IF
                    END IF
                    
            END SELECT
                       
            '-----------------------           
            restart_get_loop:
            '-----------------------
            IF break_out THEN BREAK
            IF p_length <> 1 THEN '--- do nothing if only a single char
                j = txt.height() - adj_row
                txt.color2(theme.MENU_BRIGHT & 15, theme.MENU_BRIGHT >> 4)
                FOR i = 0 TO p_length - 1                       '--- clear old
                    helpers.print_strXY2(col+i, j, " ")
                NEXT
                helpers.print_strXY2(col, j, input_str_ret_val) '--- print newly edited
                txt.plot(col + ndx, j)
            END IF
            cx16.blink_enable(TRUE)
            main.clear_kb()
            sys.wait(4)
        
        END REPEAT

        main.clear_kb()
        cx16.blink_enable(FALSE)
        RETURN

    END SUB


END MODULE