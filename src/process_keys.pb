'==============================================================================
'---    Handles all letter keys and ALT/CTRL modifers
'---    Handles all letter keys and ALT/CTRL modifers
'---    Handles all letter keys and ALT/CTRL modifers
'==============================================================================
'---    also screen refresh when needed
'==============================================================================

IMPORT screen

MODULE process_keys
    ALIAS keycode_ext = main.keycode_ext
    ALIAS keycode     = main.keycode
    ALIAS last_keys   = main.last_keys
    CONST TAGGED AS BOOL = TRUE
    CONST NOT_TAGGED AS BOOL = FALSE



    SUB letter_keys()
        IF keycode_ext = 0 THEN RETURN '--- should never happen
        'debug.say2("process_letter_keys():",keycode) 

        ALIAS ndx = main.y
        REPEAT '--- fake loop

            ' if menus.mode == menus.DIR and strings.endswith(dirs_cache.current.name,":/") {
            '     break '--- DIR and selection is ROOT
            ' }
            
            IF menus.CTRL_PRESSED THEN

                IF menus.mode = menus.DIR THEN                    '--- CTRL - DIR menu
                    IF keys.T_PRESSED IN last_keys THEN            '--- tag all files
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.U_PRESSED IN last_keys THEN            '--- untag all file
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.L_PRESSED IN last_keys THEN            '--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                 
                ELSE                                         '--- CTRL - FILE menus

                    IF keys.C_PRESSED IN last_keys THEN            '--- copy
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.D_PRESSED IN last_keys THEN            '--- delete
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.L_PRESSED IN last_keys THEN            '--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.M_PRESSED IN last_keys THEN            '--- move
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.N_PRESSED IN last_keys THEN            '--- new date
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.P_PRESSED IN last_keys THEN            '--- print
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.R_PRESSED IN last_keys THEN            '--- rename
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.S_PRESSED IN last_keys THEN            '--- search
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.V_PRESSED IN last_keys THEN            '--- view
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.T_PRESSED IN last_keys THEN            '--- tag all files
                        files_cache.tag_all(TRUE)
                        BREAK
                    END IF
                    IF keys.U_PRESSED IN last_keys THEN            '--- untag all file
                        files_cache.tag_all(FALSE)
                        BREAK
                    END IF

                END IF
                
              
            ELSEIF menus.ALT_PRESSED THEN

                IF menus.mode = menus.DIR THEN                    '--- ALT - DIR menu
                    IF keys.Q_PRESSED IN last_keys THEN 
                        flags.exit_out = prompts.ask_exit()     '--- quit, TODO, exits to the current dir, not the one it was started from
                        BREAK
                    END IF
                    IF keys.E_PRESSED IN last_keys THEN            '--- edit new-blank file
                        menus.ALT_PRESSED = FALSE               '--- getting stuck on sometimes
                        screen.store()
                        helpers.edit_file("")
                        flags.refresh_scrn = TRUE   '--- new file? check file count - then compare?
                        screen.restore()
                        BREAK
                    END IF
                    IF keys.G_PRESSED IN last_keys THEN            '--- graft dir
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.L_PRESSED IN last_keys THEN            '--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.P_PRESSED IN last_keys THEN            '--- prune dir
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF

                ELSE                                         '--- ALT - FILE menus

                     IF keys.C_PRESSED IN last_keys THEN            '--- dupe path, copy tagged
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                     IF keys.L_PRESSED IN last_keys THEN            '--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.M_PRESSED IN last_keys THEN            '--- dupe path, move tagged
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.Q_PRESSED IN last_keys THEN 
                        flags.exit_out = prompts.ask_exit()     '--- quit, TODO, exits to the current dir, not the one it was started from
                        BREAK
                    END IF
                    IF keys.T_PRESSED IN last_keys THEN            '--- tag all files
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.U_PRESSED IN last_keys THEN            '--- untag all file
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF


                END IF
                

            ELSE                                        
            
                'debug.say2("process_letter_keys-else:",keycode_ext)

                IF menus.mode = menus.DIR THEN                    '--- DIR only

                    IF keys.D_PRESSED IN last_keys THEN            '--- delete
                        IF strings.endswith(dirs_cache.current.name, iso:":/") THEN RETURN '--- ROOT folder
                        'flags.refresh_scrn = prompts.delete_dir()
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.Q_PRESSED IN last_keys THEN 
                        flags.exit_out = prompts.ask_exit()     '--- quit, TODO, exits to the current dir, not the one it was started from
                        BREAK
                    END IF
                    IF keys.M_PRESSED IN last_keys THEN            '--- make dir
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.A_PRESSED IN last_keys THEN            '--- avail
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.F_PRESSED IN last_keys THEN            '--- file spec (dir)
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.L_PRESSED IN last_keys THEN            '--- log - do we need this?
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.R_PRESSED IN last_keys THEN            '--- rename
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.T_PRESSED IN last_keys THEN            '--- tag all files
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.U_PRESSED IN last_keys THEN            '--- untag all file
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                
                ELSE                                         '------ FILE only menus ------

                    IF keys.D_PRESSED IN last_keys THEN            '--- delete
                        flags.refresh_scrn = prompts.delete_file(FALSE)
                        BREAK
                    END IF
                    IF keys.R_PRESSED IN last_keys THEN            '--- rename
                        flags.refresh_scrn = prompts.rename_file(FALSE)
                        BREAK
                    END IF
                    IF keys.Q_PRESSED IN last_keys THEN 
                        flags.exit_out = prompts.ask_exit()     '--- quit
                        BREAK
                    END IF
                    IF keys.C_PRESSED IN last_keys THEN            '--- copy
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.E_PRESSED IN last_keys THEN             '--- edit txt
                        screen.store()
                        helpers.edit_file(files_cache.current.name)
                        flags.refresh_scrn = TRUE '--- they could do a save as? (maybe file count - then compare?)
                        screen.restore()
                        BREAK
                    END IF
                    IF keys.F_PRESSED IN last_keys THEN            '--- filespec (file)                        
                        flags.refresh_scrn = prompts.file_spec()   
                        BREAK
                    END IF
                    IF keys.L_PRESSED IN last_keys THEN            '--- log
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.M_PRESSED IN last_keys THEN            '--- move
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.N_PRESSED IN last_keys THEN            '--- new date
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.P_PRESSED IN last_keys THEN            '--- print
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.T_PRESSED IN last_keys THEN            '--- tag single file
                        files_cache.tag_file(files_cache.selected_line_on_page, TRUE)
                        BREAK
                    END IF
                    IF keys.U_PRESSED IN last_keys THEN            '--- untag single file
                        files_cache.tag_file(files_cache.selected_line_on_page, FALSE)   
                        BREAK
                    END IF
                    IF keys.V_PRESSED IN last_keys THEN            '--- view
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                    IF keys.X_PRESSED IN last_keys THEN            '--- execute
                        flags.refresh_scrn = prompts.not_done_yet(NOT_TAGGED)   
                        BREAK
                    END IF
                END IF
            END IF
            BREAK
        END REPEAT '--- end fake loop, everything fires the break statement


        'debug.say("exit - process_letter_keys()")
        main.clear_kb()  

        IF flags.refresh_scrn THEN
            IF mode = menus.DIR THEN

            ELSE

            END IF
        END IF

        RETURN
    END SUB

END MODULE
