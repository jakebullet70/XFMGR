
prompts {
    alias i = main.i
    alias j = main.j
    alias input_str1 = main.g_tmp_str_buffer1
    alias input_str2 = main.g_tmp_str_buffer2
    alias input_str_ret_val = main.g_tmp_str_buffer3
    str CANCEL_INPUT = "@"
    str CR_STR = cp437:"◄╛"
    str UP_STR = cp437:"↑"

    ;txt.print_lit(cp437:"≈ IBM Pc ≈ ÇüéâäàåçêëèïîìÄ ░▒▓│┤╡╢╖╕╣║╗╝╜╛┐ ☺☻♥♦♣♠•◘○◙♂♀♪♫☼ ►◄↕‼¶§▬↨↑↓→←∟↔▲▼")

    sub draw_icons(ubyte col_arrow,ubyte col_CR,ubyte row) {
        if col_arrow != 0 helpers.print_strXY(col_arrow,row,UP_STR,clr.MENU_BRIGHT,false)
        if col_CR != 0 helpers.print_strXY(col_CR,row,CR_STR,clr.MENU_BRIGHT,false)
    }
    

    ;--- generic text input prompts text
    sub prompt_txt(str txt1, str txt2, str txt3,ubyte p_length,ubyte col,ubyte row) {
        menus.is_prompt = true                          ;--- we are in a prompt!!!
        void strings.copy("",input_str_ret_val)         ;--- clear out ret val
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
        if strings.length(txt1) != 0 {helpers.print_strXY2(1,txt.height() - 4,txt1) } 
        if strings.length(txt2) != 0 {helpers.print_strXY2(1,txt.height() - 3,txt2) } 
        if strings.length(txt3) != 0 {helpers.print_strXY2(1,txt.height() - 2,txt3) } 
        ;txt.color2(clr.MENU_EDITOR & 15, clr.MENU_EDITOR>>4)
        ;for j in 0 to p_length - 1 {  ;--- REV ON * p_length SKIPPING 
            ;helpers.print_strXY2(col+j,(txt.height() - 4) + row," ") 
            ;txt.setclr(col+i,(txt.height() - 4) + row,clr.MENU_EDITOR) 
        ;}
        ;txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
    }


    sub rename_file(bool tagged_files) {
        ;--- if tagged_files=true then rename multi files
        menus.clear_menu_area()
        prompt_txt(cp437:"RENAME File:",
                   cp437:"         To:",
                   cp437:"Enter filename mask                                  History    Ok  ESC Cancel",
                   files_folders.FILE_MAX_LEN,14,2)
                        ; 12345678901234567890123456789012345678901234567890123456789012345678901234567890
        menus.highlight_menu_keys([69,70,71],2,txt.height()-2,clr.MENU_BRIGHT)
        draw_icons(53,63,txt.height()-2)
        
        void strings.copy(files_cache.current.name,input_str_ret_val)                   ;--- copy current fname to working str        
        helpers.print_strXY(14,txt.height()-4,input_str_ret_val,clr.MENU_BRIGHT,false)  ;--- show fname
        get_txt(1,14,txt.height()-3,[keys.ESC],0,[keys.CR],0,input_str_ret_val)                      ;--- get txt loop

        if input_str_ret_val == CANCEL_INPUT return                                     ;--- cancel, bye!
        
        ;--- copy current select file into g_tmp_str_buffer1
        ;void strings.copy(files_cache.current.name,main.g_tmp_str_buffer1)
        ;debug.say(g_tmp_str_buffer1)
        return
    }
    
    sub get_txt(ubyte p_length,ubyte col,ubyte row,
            ubyte[] cancel_keys,ubyte cancel_keys_len,
            ubyte[] accept_keys,ubyte accept_keys_len,str text) {

        ;--- ESC is always cancel
        main.clear_kb()
        ubyte ndx = 0
        alias keycode = main.x
        ;alias max_len = main.y
        alias break_out = main.bool_tmp
        break_out = false
        

        if text != "" helpers.print_strXY(col,row,input_str_ret_val,clr.MENU_BRIGHT,false)
        txt.color2(clr.MENU_BRIGHT & 15, clr.MENU_BRIGHT>>4)
        txt.plot(col,row)
        cx16.blink_enable(true)
        
        repeat {
            void,keycode = cbm.GETIN()             
            if keycode == 0 continue 

            debug.say2("gt-kcode:",main.keycode_ext)
            txt.plot(col+ndx,row)
            cx16.blink_enable(false)

            ;==============================================================
            for j in 0 to cancel_keys_len {
                if cancel_keys[j] == keycode {  
                    void strings.copy(CANCEL_INPUT,input_str_ret_val)
                    break_out = true
                    break ;--- out of for loop
                }
            }
            for j in 0 to accept_keys_len {
                if accept_keys[j] == keycode {
                    void strings.copy(conv.str_ub(accept_keys[j]),input_str_ret_val)
                    break_out = true
                    break ;--- out of for loop
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


            restart_get_loop:
                helpers.print_strXY(col,row,input_str_ret_val,clr.MENU_BRIGHT,false)
                txt.plot(col+ndx,row)
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

    
    sub ask_exit() -> bool {
        menus.clear_menu_area()
        prompt_txt(cp437:"GO BYE BYE",cp437:"",cp437:"Quit and return to the x16?         [N]o  Yes  ESC Cancel",1,28,3)
        menus.highlight_menu_keys([38,43,48,49,50],4,txt.height()-2,clr.MENU_BRIGHT)
        get_txt(1,29,3,[keys.ESC,cp437:'n',cp437:'N',keys.CR],3,[cp437:'y',cp437:'Y'],1,"")
        ;return (if input_str_ret_val == CANCEL_INPUT then false else true)
        if input_str_ret_val == CANCEL_INPUT return false
        return true
    }

    

}