%import diskio
%import textio
%import strings
%import syslib  
;--- code modules
%import helpers
%import files_folders
%import linked_list_dirs
%import linked_list_files
%import strings_ext
%import menus
%import menus_prompts
%import key_const
%import debug
;---
;%encoding "cp437"
%option no_sysinit
%zeropage basicsafe


theme {
    ;--- default colors
    const ubyte TXT_NORMAL = $b1  ; 
    const ubyte TXT_BRIGHT = $b7  ; 

    const ubyte X16EDITOR_NORMAL = $b3
    const ubyte X16EDITOR_HEADER = 0 ;$3b
    const ubyte X16EDITOR_STATUS = $7b

    const ubyte MENU_NORMAL = $b3  ;
    const ubyte MENU_BRIGHT = $b7  ;
    ;const ubyte MENU_EDITOR = $3b  ;  reverse of MENU_BRIGHT

    const ubyte ROW_HILIGHT = $e1
    const ubyte BOXES = $be ;
}

flags {
    bool refresh_scrn = false
    bool exit_out = false
}

main {
    ;--- tmp vars to be used wherever
    str g_tmp_str_buffer1 = "?" * 160
    str g_tmp_str_buffer2 = "?" * 160
    str g_tmp_str_buffer3 = "?" * 160
    ubyte @zp i,j,x,y = 0
    bool bool_tmp = false
    str start_dir = "?" * 80
    
    uword old_keyhdl                       ;--- custom KB handler var
    ubyte keycode_ext, keycode,kb_ndx      ;--- key press vars
    ubyte[5] last_keys
    
    sub start() {

        void strings.copy(diskio.curdir(),start_dir)
        cx16.set_screen_mode(0)
        txt.color2(theme.TXT_NORMAL & 15, theme.TXT_NORMAL>>4)
        txt.clear_screen()        
        
        txt.cp437()                     ;--- enable ISO character set 
        ;txt.lowercase()
        helpers.set_characters(true)    ;--- use ISO characters for box drawing
        helpers.draw_main_scrn()

        menus.mode = menus.FILE ;--- default for the moment
        menus.draw()

        debug.init(0)
        ;debug.say("debug inited!")

        files_cache.init()
        dirs_cache.init()

        ;void files_folders.read_dirs(8)        ;--- read files into files_cache
        ;files_cache.draw_files_2_scrn()
        void files_folders.read_files(8)        ;--- read files into files_cache
        files_cache.draw_files_2_scrn()

        custom_keyboard_handler_on_off(true)    ;--- set custom KB handler ==> sub &kb_handler
        ;---------------------------------------------
        ;--- Main key loop!  
        ;---------------------------------------------
        main_key_loop()
        ;---------------------------------------------
        ;--- End, lets bail from here!
        ;---------------------------------------------
        custom_keyboard_handler_on_off(false)       ;--- restore old KB handler
        txt.iso_off()
        ;txt.uppercase()
        txt.clear_screen()
        txt.print("bye!")
        return

    }    


    
    ;--- main character input loop       
    sub main_key_loop() {
        repeat {

            if (not menus.CTRL_PRESSED and not menus.ALT_PRESSED) { 
                menus.clear_modifier_flags() 
            }
            

            if (not menus.is_dir_menu) and (not menus.is_file_menu) or menus.is_prompt {
                ;--- what menu is visible? draw base menu
                if (not menus.CTRL_PRESSED and not menus.ALT_PRESSED) or 
                        (not menus.is_alt_dir_menu and not menus.is_alt_file_menu and 
                        not menus.is_ctrl_dir_menu and not menus.is_ctrl_file_menu) { 
                    menus.draw() ;--- draw non ALT / CTRL menu
                    continue
                }
            }
            
            
            ;--- check modifer keys, draw ALT / CTRL menu or process a key
            if menus.ALT_PRESSED or menus.CTRL_PRESSED {
                if menus.is_alt_dir_menu or menus.is_alt_file_menu or menus.is_ctrl_dir_menu or menus.is_ctrl_file_menu { 
                    if keycode != 0 or keycode_ext !=0 process_letter_keys()    ;--- process modifer + key 
                    continue                                                    ;--- menu is already shown, back to grab keys
                } 
                menus.draw()                                             ;--- draw CTRL / ALT menus
                continue
            }

            get_key_again:
                ;debug.say("start-get-kb")
                ;cx16.kbdbuf_clear()
                ;keycode_ext = keycode = 0               ;--- reset key vars, keycode_ext var contains modifer key
                void,keycode = cbm.GETIN()              ;--- custom KB handler points to ==> &kb_handler
                ;keycode = cx16.kbdbuf_get()
                if keycode == 0 and keycode_ext == 0 goto get_key_again
            
            


            if not menus.CTRL_PRESSED and not menus.ALT_PRESSED {
                ;--- key strokes - movement up / down / pgup / pgdn
                when keycode {
                    keys.DN_ARROW_PRESSED  -> { 
                        if menus.mode == menus.DIR { 
                            ;dirs_cache.key_down()  
                        } else {
                            files_cache.key_down() 
                        } 
                        continue
                    }
                    keys.UP_ARROW_PRESSED -> {
                        if menus.mode == menus.DIR { 
                            ;dirs_cache.key_up()  
                        } else {
                            files_cache.key_up() 
                        } 
                        continue
                    }
                    keys.PAGE_DN_PRESSED  -> { 
                        ; if menus.mode == menus.DIR { 
                        ;     ;dirs_cache.key_up()  
                        ; } else {
                        ;     files_cache.key_up() 
                        ; } 
                        ; continue
                    }    
                    keys.PAGE_UP_PRESSED  -> {
                        ; if menus.mode == menus.DIR { 
                        ;     ;dirs_cache.key_up()  
                        ; } else {
                        ;     files_cache.key_up() 
                        ; } 
                        ;  continue
                    } 
                }
            }
            
            if keycode == 0 continue
            process_letter_keys()           ;--- process keys
            if flags.exit_out break         ;--- break out of loop
            
        } ;--- repeat loop
    }



    sub process_letter_keys() {
        if keycode_ext == 0 return ;--- should never happen
        ;debug.say2("process_letter_keys():",keycode) 
        
        repeat { ;--- fake loop
            
            if menus.CTRL_PRESSED {                 ;--- CTRL key   

              
            } else if menus.ALT_PRESSED {           ;--- ALT key
                if keys.Q_PRESSED in last_keys { 
                    flags.exit_out = prompts.ask_exit()   ;--- quit, TODO, exits to the current dir, not the one it was started from
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
        clear_kb()  

        if flags.refresh_scrn {
            if mode == menus.DIR {

            } else {

            }
        }

        return
    }

    ;--------------------------------------------------------------------------
    ;--------------------------------------------------------------------------
    ;--------------------------------------------------------------------------

    sub clear_kb() {
        cx16.kbdbuf_clear()
        for i in 0 to 4 { ;--- clear the kb stack 
            last_keys[i] = 0    
        }
    }

    sub custom_keyboard_handler_on_off(bool turn_on) {
        if turn_on {
            sys.set_irqd()
            old_keyhdl = cx16.KEYHDL
            cx16.KEYHDL = &kb_handler
            sys.clear_irqd()  
        } else 
        {
            sys.set_irqd()
            cx16.KEYHDL = old_keyhdl
            sys.clear_irqd()
        }
    }

    sub kb_handler(ubyte keynum) -> ubyte {
        ; NOTE: this handler routine expects the keynum in A and return value in A
        ;       which is thankfully how prog8 translates this subroutine's calling convention.
        ; NOTE: it may be better to store the keynum somewhere else and let the main program
        ;       loop figure out what to do with it, rather than putting it all in the handler routine

        ;debug.say2("keyhandler:",keynum)

        ;--- check CTRL / ALT key and set flag
        when keynum { 
            keys.EXT_CTRL_UP  -> { 
                menus.CTRL_PRESSED = false 
                ;return 0   
            }
            keys.EXT_CTRL_DN  -> { 
                menus.CTRL_PRESSED = true  
                ;return 0   
            }
            keys.EXT_ALT_UP   -> { 
                menus.ALT_PRESSED  = false 
                ;return 0   
            }
            keys.EXT_ALT_DN   -> { 
                menus.ALT_PRESSED  = true
                ;return 0   
            }
        }  ;--- return 0 eats the key event

        ;--- save the last 5 keycodes because...
        ;--- ALT-Q (or modifyer and key) is 4 bytes --> (ALT up and down) and (Q up and down)
        ;--- 4 bytes! ;) and a 5th just for fun!
        if kb_ndx == 5 kb_ndx = 0
        last_keys[kb_ndx] = keynum
        kb_ndx++

        keycode_ext = keynum
        return keynum           ;--- is not returning ALT / CTRL codes

        ; ;--- By returning 0 (in A) we will eat this key event. 
        ; ;--- Return the original keynum value to pass it through.
        ; return 0        
    }
}