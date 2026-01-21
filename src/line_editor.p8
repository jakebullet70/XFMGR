;==============================================================================
;---   
;---   line_editor.p8,  single line editor with blining cursor
;---   
;==============================================================================
;---   
;==============================================================================


line_editor {

    alias i = main.i
    alias j = main.j
    alias input_str_ret_val = main.g_tmp_str_buffer3
    str CANCEL_INPUT = "@"
    
    sub get_txt(ubyte p_length,ubyte col,ubyte adj_row,
            ubyte[] cancel_keys,ubyte cancel_keys_len,
            ubyte[] accept_keys,ubyte accept_keys_len,str text) {

        ;--- ESC is always cancel
        main.clear_kb()
        ubyte ndx = 0
        alias keycode = main.x
        ;alias max_len = main.y
        alias break_out = main.bool_tmp
        break_out = false
        

        if text != "" helpers.print_strXY(col,txt.height()-adj_row,input_str_ret_val,theme.MENU_BRIGHT,false)
        txt.color2(theme.MENU_BRIGHT & 15, theme.MENU_BRIGHT>>4)
        txt.plot(col,txt.height()-adj_row)
        cx16.blink_enable(true)
        
        repeat {
            void,keycode = cbm.GETIN()             
            if keycode == 0 continue 

            ;debug.say2("gt-kcode:",main.keycode_ext)
            txt.plot(col+ndx,txt.height()-adj_row)
            cx16.blink_enable(false)

            ;==============================================================
            for j in 0 to cancel_keys_len {
                if cancel_keys[j] == keycode {  
                    void strings.copy(CANCEL_INPUT,input_str_ret_val)
                    break_out = true
                    break ;--- breaks out of FOR loop
                }
            }
            for j in 0 to accept_keys_len {
                if accept_keys[j] == keycode {
                    void strings.copy(conv.str_ub(accept_keys[j]),input_str_ret_val)
                    break_out = true
                    break ;--- breaks out of FOR loop
                }
            }
            ;==============================================================
            if keys.LEFT_ARROW  in main.last_keys { 
                if ndx > 0 ndx-- 
                goto restart_get_loop
            }
            if keys.RIGHT_ARROW in main.last_keys { 
                if ndx < files_folders.FILE_MAX_LEN ndx++ 
                goto restart_get_loop
            }
           
            when main.keycode_ext {
                keys.END   -> { ndx = strings.length(input_str_ret_val) - 1 }
                keys.HOME  -> { ndx = 0 }
                keys.DELETE  -> { 
                }
                keys.BACKSPACE -> {
                }
                keys.INSERT -> {
                }
                
            }

            ;-----------------------           
            restart_get_loop:
            ;-----------------------
            helpers.print_strXY(col,txt.height()-adj_row,input_str_ret_val,theme.MENU_BRIGHT,false)
            txt.plot(col+ndx,txt.height()-adj_row)
            cx16.blink_enable(true)
            main.clear_kb()
            if break_out break
            sys.wait(4)
        
        }

        main.clear_kb()
        ;debug.say("break")
        cx16.blink_enable(false)
        return
    }

}