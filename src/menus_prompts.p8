
prompts {
    alias i = main.i
    alias j = main.j
    alias input_str1 = main.g_tmp_str_buffer1
    alias input_str2 = main.g_tmp_str_buffer2
    alias input_str_ret_val = main.g_tmp_str_buffer3
    str CANCEL_INPUT = "@"

    
    ;--- generic text input prompts text
    sub prompt_txt(str txt1, str txt2, str txt3,ubyte p_length,ubyte col,ubyte row) {
        menus.is_prompt = true                          ;--- we are in a prompt!!!
        void strings.copy("",input_str_ret_val)         ;--- clear out ret val
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
        if strings.length(txt1) != 0 {helpers.print_strXY2(1,txt.height() - 4,txt1) } 
        if strings.length(txt2) != 0 {helpers.print_strXY2(1,txt.height() - 3,txt2) } 
        if strings.length(txt3) != 0 {helpers.print_strXY2(1,txt.height() - 2,txt3) } 
        txt.color2(clr.MENU_EDITOR & 15, clr.MENU_EDITOR>>4)
        for j in 0 to p_length - 1 {
            helpers.print_strXY2(col+j,(txt.height() - 5) + row," ") 
            ;txt.setclr(col+i,(txt.height() - 6) + row,clr.MENU_EDITOR) 
        }
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
    }


    sub ask_exit() -> bool {
        menus.clear_menu_area()
        prompt_txt(cp437:"GO BYE BYE",cp437:"",cp437:"Quit and return to the x16?         [N]o  Yes  ESC Cancel",1,28,3)
        menus.highlight_menu_keys([38,43,48,49,50],4,txt.height()-2,clr.MENU_BRIGHT)
        get_txt(1,28,3,[keys.ESC,cp437:'n',cp437:'N',keys.CR],3,[cp437:'y',cp437:'Y'],1,"")
        ;return (input_str_ret_val == CANCEL_INPUT)
        if input_str_ret_val == CANCEL_INPUT {
             return false
        }
        return true
    }

    

    
    sub get_txt(ubyte p_length,ubyte col,ubyte row,ubyte[] cancel_keys,ubyte cancel_keys_len,ubyte[] accept_keys,ubyte accept_keys_len,str txt) {

        ;--- ESC is always cancel
        main.clear_kb()
        alias ndx = main.i
        alias j = main.j
        alias keycode = main.x
        alias max_len = main.y
        ndx = 1
        
        ;input_str_ret_val = txt
        bool lo = true
        repeat {
            void,keycode = cbm.GETIN()             
            if keycode == 0 continue 
            debug.say2("gt-kcode:",keycode)

            for j in 0 to cancel_keys_len {
                if cancel_keys[j] == keycode {  
                    void strings.copy(CANCEL_INPUT,input_str_ret_val)
                    return
                }
            }
            for j in 0 to accept_keys_len {
                if accept_keys[j] == keycode {
                    void strings.copy(conv.str_ub(accept_keys[j]),input_str_ret_val)
                    return    
                }
            }

            ; if keycode in cancel_keys {  FAILS!!!!!!!!!!!!!!!
            ;     void strings.copy(input_str_ret_val,CANCEL_INPUT)
            ;     break
            ; }

            ; when keycode {
            ;     keys.LEFT_ARROW  -> { 
                
            ;     }
            ;     keys.RIGHT_ARROW -> {
                
            ;     }
            ;     keys.DELETE  -> { 
                
            ;     }
            ;     keys.BACKSPACE -> {
                
            ;     }
            ;     keys.INSERT -> {
                
            ;     }
                
            ; }
        }
    }


}