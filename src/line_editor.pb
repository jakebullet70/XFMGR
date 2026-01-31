'==============================================================================
'---   
'---   line_editor.pb,  single line editor with blining cursor
'---   
'==============================================================================
'---   
'==============================================================================


MODULE line_editor

    ALIAS i = main.i
    ALIAS j = main.j
    ALIAS input_str_ret_val = main.g_tmp_str_buffer3
    DIM CANCEL_INPUT AS STRING = "@"
    
    SUB get_txt(p_length AS UBYTE, col AS UBYTE, adj_row AS UBYTE,
            cancel_keys[] AS UBYTE, cancel_keys_len AS UBYTE,
            accept_keys[] AS UBYTE, accept_keys_len AS UBYTE, text AS STRING)

        '--- ESC is always cancel
        main.clear_kb()
        DIM ndx AS UBYTE = 0
        ALIAS keycode = main.x
        'alias max_len = main.y
        ALIAS break_out = main.bool_tmp
        break_out = FALSE
        

        IF text <> "" THEN helpers.print_strXY(col, txt.height() - adj_row, input_str_ret_val, theme.MENU_BRIGHT, FALSE)
        txt.color2(theme.MENU_BRIGHT & 15, theme.MENU_BRIGHT >> 4)
        txt.plot(col, txt.height() - adj_row)
        cx16.blink_enable(TRUE)
        
        REPEAT
            VOID, keycode = cbm.GETIN()             
            IF keycode = 0 THEN CONTINUE

            'debug.say2("gt-kcode:",main.keycode_ext)
            txt.plot(col + ndx, txt.height() - adj_row)
            cx16.blink_enable(FALSE)

            '==============================================================
            FOR j = 0 TO cancel_keys_len
                IF cancel_keys[j] = keycode THEN
                    VOID strings.copy(CANCEL_INPUT, input_str_ret_val)
                    break_out = TRUE
                    BREAK '--- breaks out of FOR loop
                END IF
            NEXT
            FOR j = 0 TO accept_keys_len
                IF accept_keys[j] = keycode THEN
                    VOID strings.copy(conv.str_ub(accept_keys[j]), input_str_ret_val)
                    break_out = TRUE
                    BREAK '--- breaks out of FOR loop
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
           
            SELECT CASE main.keycode_ext
                CASE keys.ENDKEY
                    ndx = strings.length(input_str_ret_val) - 1
                CASE keys.HOME
                    ndx = 0
                CASE keys.DELETE
                
                CASE keys.BACKSPACE
                
                CASE keys.INSERT
                
            END SELECT

            '-----------------------           
            restart_get_loop:
            '-----------------------
            helpers.print_strXY(col, txt.height() - adj_row, input_str_ret_val, theme.MENU_BRIGHT, FALSE)
            txt.plot(col + ndx, txt.height() - adj_row)
            cx16.blink_enable(TRUE)
            main.clear_kb()
            IF break_out THEN BREAK
            sys.wait(4)
        
        END REPEAT

        main.clear_kb()
        'debug.say("break")
        cx16.blink_enable(FALSE)
        RETURN
    END SUB

END MODULE