;==============================================================================
;---    Handles all letter keys and ALT/CTRL modifers
;---    Handles all letter keys and ALT/CTRL modifers
;---    Handles all letter keys and ALT/CTRL modifers
;==============================================================================
;---    also screen refresh when needed
;==============================================================================

%import screen

process_keys {
    alias keycode_ext = main.keycode_ext
    alias keycode     = main.keycode
    alias last_keys   = main.last_keys
    const bool TAGGED = true
    const bool NOT_TAGGED = false



    sub letter_keys() {
        if keycode_ext == 0 return ;--- should never happen
        ;debug.say2("process_letter_keys():",keycode) 

        alias ndx = main.y
        repeat { ;--- fake loop

            ; if menus.mode == menus.DIR and strings.endswith(dirs_cache.current.name,":/") {
            ;     break ;--- DIR and selection is ROOT
            ; }
            
            if menus.CTRL_PRESSED {                            

                if menus.mode == menus.DIR {                    ;--- CTRL - DIR menu
                    if keys.T_PRESSED in last_keys {            ;--- tag all files
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.U_PRESSED in last_keys {            ;--- untag all file
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.L_PRESSED in last_keys {            ;--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                 
                } else {                                         ;--- CTRL - FILE menus

                    if keys.C_PRESSED in last_keys {            ;--- copy
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.D_PRESSED in last_keys {            ;--- delete
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.L_PRESSED in last_keys {            ;--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.M_PRESSED in last_keys {            ;--- move
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.N_PRESSED in last_keys {            ;--- new date
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.P_PRESSED in last_keys {            ;--- print
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.R_PRESSED in last_keys {            ;--- rename
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.S_PRESSED in last_keys {            ;--- search
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.V_PRESSED in last_keys {            ;--- view
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.T_PRESSED in last_keys {            ;--- tag all files
                        files_cache.tag_all(true)
                        break
                    }
                    if keys.U_PRESSED in last_keys {            ;--- untag all file
                        files_cache.tag_all(false)
                        break
                    }

                }
                
              
            } else if menus.ALT_PRESSED {                   

                if menus.mode == menus.DIR {                    ;--- ALT - DIR menu
                    if keys.Q_PRESSED in last_keys { 
                        flags.exit_out = prompts.ask_exit()     ;--- quit, TODO, exits to the current dir, not the one it was started from
                        break
                    }
                    if keys.E_PRESSED in last_keys {            ;--- edit new-blank file
                        screen.store()
                        helpers.edit_file("")       ;--- BOOM, TODO: locs up on return
                        flags.refresh_scrn = true   ;--- new file? check file count - then compare?
                        screen.restore()
                        break
                    }
                    if keys.G_PRESSED in last_keys {            ;--- graft dir
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.L_PRESSED in last_keys {            ;--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.P_PRESSED in last_keys {            ;--- prune dir
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }

                } else {                                         ;--- ALT - FILE menus

                     if keys.C_PRESSED in last_keys {            ;--- dupe path, copy tagged
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                     if keys.L_PRESSED in last_keys {            ;--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.M_PRESSED in last_keys {            ;--- dupe path, move tagged
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.Q_PRESSED in last_keys { 
                        flags.exit_out = prompts.ask_exit()     ;--- quit, TODO, exits to the current dir, not the one it was started from
                        break
                    }
                    if keys.T_PRESSED in last_keys {            ;--- tag all files
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.U_PRESSED in last_keys {            ;--- untag all file
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }


                }
                

            } else {                                        
            
                ;debug.say2("process_letter_keys-else:",keycode_ext)

                if menus.mode == menus.DIR {                    ;--- DIR only

                    if keys.D_PRESSED in last_keys {            ;--- delete
                        if strings.endswith(dirs_cache.current.name,iso:":/") return ;--- ROOT folder
                        ;flags.refresh_scrn = prompts.delete_dir()
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.Q_PRESSED in last_keys { 
                        flags.exit_out = prompts.ask_exit()     ;--- quit, TODO, exits to the current dir, not the one it was started from
                        break
                    }
                    if keys.M_PRESSED in last_keys {            ;--- make dir
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.A_PRESSED in last_keys {            ;--- avail
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.F_PRESSED in last_keys {            ;--- file spec (dir)
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.L_PRESSED in last_keys {            ;--- log - do we need this?
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.R_PRESSED in last_keys {            ;--- rename
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.T_PRESSED in last_keys {            ;--- tag all files
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.U_PRESSED in last_keys {            ;--- untag all file
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                
                } else {                                         ;------ FILE only menus ------

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
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.E_PRESSED in last_keys {             ;--- edit txt
                        screen.store()
                        helpers.edit_file(files_cache.current.name)
                        flags.refresh_scrn = true ;--- they could do a save as? (maybe file count - then compare?)
                        screen.restore()
                        break
                    }
                    if keys.F_PRESSED in last_keys {            ;--- filespec
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.L_PRESSED in last_keys {            ;--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.M_PRESSED in last_keys {            ;--- move
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.N_PRESSED in last_keys {            ;--- new date
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.P_PRESSED in last_keys {            ;--- print
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.T_PRESSED in last_keys {            ;--- tag
                        files_cache.tag_file(files_cache.selected_line_on_page,true)
                        break
                    }
                    if keys.U_PRESSED in last_keys {            ;--- untag
                        files_cache.tag_file(files_cache.selected_line_on_page,false)   
                        break
                    }
                    if keys.V_PRESSED in last_keys {            ;--- view
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }
                    if keys.X_PRESSED in last_keys {            ;--- execute
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        break
                    }


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
