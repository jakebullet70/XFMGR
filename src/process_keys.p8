;==============================================================================
;---    Handles all letter keys and ALT/CTRL modifers
;---    Handles all letter keys and ALT/CTRL modifers
;---    Handles all letter keys and ALT/CTRL modifers
;==============================================================================
;---    also screen refresh when needed
;==============================================================================


process_keys {
    alias keycode_ext = main.keycode_ext
    alias keycode     = main.keycode
    alias last_keys   = main.last_keys


    sub letter_keys() {
        if keycode_ext == 0 return ;--- should never happen
        ;debug.say2("process_letter_keys():",keycode) 
        
        repeat { ;--- fake loop
            
            if menus.CTRL_PRESSED {                 ;--- CTRL key   

              
            } else if menus.ALT_PRESSED {           ;--- ALT key
                if keys.Q_PRESSED in last_keys { 
                    flags.exit_out = prompts.ask_exit()   ;--- quit, TODO, exits to the current dir, not the one it was started from
                    break
                }


            } else {                                ;--- key - no modifier
                ;debug.say2("process_letter_keys-else:",keycode_ext)
                if keys.D_PRESSED in last_keys {            ;--- delete
                    flags.refresh_scrn = prompts.delete_file(false)
                    break
                }
                if keys.R_PRESSED in last_keys {            ;--- rename
                    flags.refresh_scrn = prompts.rename_file(false)
                    break
                }      
                if keys.Q_PRESSED in last_keys { 
                    flags.exit_out = prompts.ask_exit()     ;--- quit
                    break
                }      
                if keys.C_PRESSED in last_keys {            ;--- copy
                    flags.refresh_scrn = prompts.not_done_yet()   
                    break
                }
                if keys.E_PRESSED in last_keys {            ;--- edit txt
                    ;flags.refresh_scrn = prompts.not_done_yet()   
                    helpers.edit_file(iso:"TEST1.P8")
                    break
                }
                if keys.F_PRESSED in last_keys {            ;--- filespec
                    flags.refresh_scrn = prompts.not_done_yet()   
                    break
                }
                 if keys.L_PRESSED in last_keys {            ;--- log
                    flags.refresh_scrn = prompts.not_done_yet()   
                    break
                }
                 if keys.M_PRESSED in last_keys {            ;--- move
                    flags.refresh_scrn = prompts.not_done_yet()   
                    break
                }

            }
            break
        } ;--- end fake loop, everything fires the break statement

        ;debug.say("exit - process_letter_keys()")
        main.clear_kb()  

        if flags.refresh_scrn {
            if mode == menus.DIR {

            } else {

            }
        }

        return
    }

}
