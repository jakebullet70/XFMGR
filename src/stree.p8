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
%import process_keys
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
    str g_tmp_str_buffer1 = "?" * 160       ;--- tmp vars to be (re)used wherever
    str g_tmp_str_buffer2 = "?" * 160
    str g_tmp_str_buffer3 = "?" * 160
    ubyte @zp i,j,x,y = 0
    bool bool_tmp = false
    uword uword_tmp1,uword_tmp2
    
    uword old_keyhdl                        ;--- custom KB handler var
    ubyte keycode_ext,keycode,kb_ndx        ;--- key press vars
    ubyte[5] last_keys

    const ubyte DEF_PATH_LENGTH = 80
    str start_dir = "?" * DEF_PATH_LENGTH    ;--- start folder, is 80 enough?

    
    sub start() {

        debug.init(0)
        cx16.set_screen_mode(0)
        txt.color2(theme.TXT_NORMAL & 15, theme.TXT_NORMAL>>4)
        txt.clear_screen()        
        
        txt.cp437()                     ;--- enable ISO-IBM character set 
        ;txt.lowercase()
        helpers.set_characters(true)    ;--- use ISO characters for box drawing
        helpers.draw_main_scrn()

        void strings.copy(diskio.curdir(),start_dir)  ;--- save starup folder
        ;debug.say(start_dir)
        menus.mode = menus.DIR 
        menus.draw()
        
        dirs_cache.init_clear()
        void files_folders.read_dirs(8)        ;--- read dirs into dir_cache
        dirs_cache.draw_dirs_2_scrn()

        files_cache.init_clear()
        void files_folders.read_files(8)        ;--- read files into files_cache
        files_cache.draw_files_2_scrn(0)

        select_focus()

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


    sub select_focus() {
        if menus.mode == menus.FILE {
            dirs_cache.lost_focus()
            files_cache.set_focus()
        } else {
            dirs_cache.set_focus()
            files_cache.lost_focus()
        }
        menus.draw()
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
                    if keycode != 0 or keycode_ext !=0 process_keys.letter_keys()       ;--- process modifer + key 
                    continue                                                            ;--- menu is already shown, back to grab keys
                } 
                menus.draw()                                                            ;--- draw CTRL / ALT menus
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
                ;debug.say2("keycode:",keycode)
                ;sys.wait(200)
                when keycode {
                    keys.CR,keys.TAB -> { ;--- swap FILE / DIR focus
                        menus.mode = if menus.mode == menus.FILE then menus.DIR else menus.FILE
                        select_focus()
                    }
                    keys.DN_ARROW_PRESSED  -> { 
                        if menus.mode == menus.DIR { 
                            if dirs_cache.num_dirs <= 1 continue
                            dirs_cache.key_down()  
                        } else {
                            if files_cache.num_files == 0 continue
                            files_cache.key_down() 
                        } 
                        continue
                    }
                    keys.UP_ARROW_PRESSED -> {
                        if menus.mode == menus.DIR { 
                            if dirs_cache.num_dirs <= 1 continue
                            dirs_cache.key_up()  
                        } else {
                            if files_cache.num_files == 0 continue
                            files_cache.key_up() 
                        } 
                        continue
                    }
                    keys.PAGE_DN_PRESSED  -> { 
                        ; if menus.mode == menus.DIR { 
                        ;     ;dirs_cache.key_up()  
                        ; } else {
                        ;     if files_cache.num_files == 0 continue
                        ;     files_cache.key_up() 
                        ; } 
                        ; continue
                    }    
                    keys.PAGE_UP_PRESSED  -> {
                        ; if menus.mode == menus.DIR { 
                        ;     ;dirs_cache.key_up()  
                        ; } else {
                        ;    if files_cache.num_files == 0 continue
                        ;     files_cache.key_up() 
                        ; } 
                        ;  continue
                    } 
                }
            }
            
            if keycode == 0 continue
            process_keys.letter_keys()           ;--- process keys
            if flags.exit_out break         ;--- break out of loop
            
        } ;--- repeat loop
    }

   
    ;--------------------------------------------------------------------------
    ;----------- KB handler stuff ---------------------------------------------
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
            keys.EXT_CTRL_UP  -> menus.CTRL_PRESSED = false 
            keys.EXT_CTRL_DN  -> menus.CTRL_PRESSED = true  
            keys.EXT_ALT_UP   -> menus.ALT_PRESSED  = false 
            keys.EXT_ALT_DN   -> menus.ALT_PRESSED  = true
        }  

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