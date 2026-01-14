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
%import menus_keys
%import key_const
%import debug
;---
;%encoding "cp437"
%option no_sysinit
%zeropage basicsafe


clr {
    ;--- default colors
    const ubyte TXT_NORMAL = $b1  ; 
    const ubyte TXT_BRIGHT = $b7  ; 
    const ubyte MENU_NORMAL = $b3  ;
    const ubyte MENU_BRIGHT = $b7  ; 
    const ubyte ROW_HILIGHT = $e1
    const ubyte BOXES = $be ;
}

main {
    ;--- tmp vars to be used wherever
    str g_tmp_str_buffer1 = "?" * 255
    str g_tmp_str_buffer2 = "?" * 255
    str g_tmp_str_buffer3 = "?" * 255
    ubyte @zp i,j,x,y = 0
    bool bool_tmp = false

    uword old_keyhdl                       ;--- custom KB handler var
    ubyte keycode_ext, keycode,kb_ndx      ;--- key press vars
    ubyte[5] last_keys
    bool exit_out = false

    sub start() {

        cx16.set_screen_mode(0)
        txt.color2(clr.TXT_NORMAL & 15, clr.TXT_NORMAL>>4)
        txt.clear_screen()        
        
        txt.cp437()                     ;--- enable ISO character set 
        txt.lowercase()
        helpers.set_characters(true)    ;--- use ISO characters for box drawing
        helpers.draw_main_scrn()

        menus.mode = menus.FILE ;--- default for the moment
        menus.draw(0)

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
        txt.uppercase()
        txt.clear_screen()
        txt.print("bye!")
        return

        ;--- main character input loop       
        sub main_key_loop() {
        
            repeat {

                ;cx16.kbdbuf_clear()
                ;keycode_ext = keycode = 0               ;--- reset key vars, keycode_ext var contains modifer key
                void,keycode = cbm.GETIN()              ;--- custom KB handler points to ==> &kb_handler
                ;keycode = cx16.kbdbuf_get()
                if keycode == 0 and keycode_ext == 0 continue 
                
                ;--- what menu is visible? draw base menu
                if (menus.is_alt_dir_menu or menus.is_alt_file_menu or menus.is_ctrl_dir_menu or menus.is_ctrl_file_menu) and 
                        (not menus.CTRL_PRESSED and not menus.ALT_PRESSED) { 
                    menus.draw(0) ;--- draw non ALT / CTRL menu
                    continue
                }
                
                ;--- check modifer keys, draw ALT / CTRL menu or process a key
                if menus.ALT_PRESSED or menus.CTRL_PRESSED {
                    if menus.is_alt_dir_menu or menus.is_alt_file_menu or menus.is_ctrl_dir_menu or menus.is_ctrl_file_menu { 
                        if keycode != 0 or keycode_ext !=0 process_letter_keys()    ;--- process modifer + key 
                        continue                                                    ;--- menu is already shown, back to grab keys
                    } 
                    menus.draw(keycode)                                             ;--- draw CTRL / ALT menus
                }


                if not menus.CTRL_PRESSED and not menus.ALT_PRESSED {
                    ;--- key strokes - movement up / down / pgup / pgdn
                    when keycode {
                        27  -> { exit_out = true }  ; ESC key to end program

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
                if exit_out break
                continue                        ;--- start loop again
            }
            return
        }



        sub process_letter_keys() {
            ;debug.say("jjjjjjjjjjjjjjjjjjjj")
            if keycode == 0 return ;--- should never happen

            
            repeat { ;--- fake loop
                
                if menus.CTRL_PRESSED {                 ;--- CTRL key   
                    
                } else if menus.ALT_PRESSED {           ;--- ALT key

                } else {                                ;--- key - no modifier
                    if keys.Q_PRESSED in last_keys {
                        exit_out = ask_exit() 
                        break
                    }
                }
            } ;--- end fake loop, everything fires the break statement


            ;--- clear the kb stack and exit
            for i in 0 to 4 { 
                last_keys[i] = 0    
            }
            return
        }

        sub ask_exit() -> bool {
            menus.clear_menu_area()
            ;prompt_txt("Quit and return to x16")
            sys.wait(30)
            return true
        }


        sub custom_keyboard_handler_on_off(bool turn_on) {
            if turn_on {
                sys.set_irqd()
                old_keyhdl = cx16.KEYHDL
                cx16.KEYHDL = &kb_handler
                sys.clear_irqd()  
            } else {
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
                keys.EXT_CTRL_UP  -> { menus.CTRL_PRESSED = false }
                keys.EXT_CTRL_DN  -> { menus.CTRL_PRESSED = true  }
                keys.EXT_ALT_UP   -> { menus.ALT_PRESSED  = false }
                keys.EXT_ALT_DN   -> { menus.ALT_PRESSED  = true  }
            }

            ;--- save the last 5 keycodes
            if kb_ndx > 4 kb_ndx = 0
            last_keys[kb_ndx] = keynum
            kb_ndx++

            keycode_ext = keynum
            return keynum ;--- is not returning ALT / CTRL codes

            ; txt.print_ubhex(keynum, true)
            ; txt.spc()
            ; if keynum & $80 !=0
            ;     txt.chrout('u')
            ; else
            ;     txt.chrout('d')
            ; txt.nl()

            ; if keynum==$6e {
            ;     ; escape stops the program
            ;     main.stop_program = true
            ; }
            ; ;--- By returning 0 (in A) we will eat this key event. 
            ; ;--- Return the original keynum value to pass it through.
            ; return 0        
        }

    }
}