IMPORT diskio
IMPORT textio
IMPORT strings
IMPORT syslib  
'--- code modules
IMPORT helpers
IMPORT files_folders
IMPORT linked_list_dirs
IMPORT linked_list_files
IMPORT strings_ext
IMPORT menus
IMPORT menus_prompts
IMPORT key_const
IMPORT debug
IMPORT process_keys
'---
'ENCODING "cp437"
OPTION no_sysinit
ZEROPAGE basicsafe


MODULE theme
    '--- default colors
    CONST TXT_NORMAL AS UBYTE = $b1  ' 
    CONST TXT_BRIGHT AS UBYTE = $b7  ' 

    CONST X16EDITOR_NORMAL AS UBYTE = $b3
    CONST X16EDITOR_HEADER AS UBYTE = 0 '$3b
    CONST X16EDITOR_STATUS AS UBYTE = $7b

    CONST MENU_NORMAL AS UBYTE = $b3  '
    CONST MENU_BRIGHT AS UBYTE = $b7  '
    'CONST MENU_EDITOR AS UBYTE = $3b  '  reverse of MENU_BRIGHT

    CONST ROW_HILIGHT AS UBYTE = $e1
    CONST BOXES AS UBYTE = $be '
END MODULE

MODULE flags
    DIM refresh_scrn AS BOOL = FALSE
    DIM exit_out AS BOOL = FALSE
END MODULE

MODULE main
    DIM g_tmp_str_buffer1 AS STRING = "?" * 160       '--- tmp vars to be (re)used wherever
    DIM g_tmp_str_buffer2 AS STRING = "?" * 160
    DIM g_tmp_str_buffer3 AS STRING = "?" * 160
    DIM i, j, x, y AS UBYTE @zp = 0
    DIM bool_tmp AS BOOL = FALSE
    DIM uword_tmp1, uword_tmp2 AS UWORD
    
    DIM old_keyhdl AS UWORD                        '--- custom KB handler var
    DIM keycode_ext, keycode, kb_ndx AS UBYTE        '--- key press vars
    DIM last_keys[5] AS UBYTE

    CONST DEF_PATH_LENGTH AS UBYTE = 80
    DIM start_dir AS STRING = "?" * DEF_PATH_LENGTH    '--- start folder, is 80 enough?

    
    SUB start()

        debug.init(0)
        cx16.set_screen_mode(0)
        txt.color2(theme.TXT_NORMAL BITAND 15, theme.TXT_NORMAL SHR 4)
        txt.clear_screen()        
        
        txt.cp437()                     '--- enable ISO-IBM character set 
        'txt.lowercase()
        helpers.set_characters(TRUE)    '--- use ISO characters for box drawing
        helpers.draw_main_scrn()

        VOID strings.copy(diskio.curdir(), start_dir)  '--- save starup folder
        'debug.say(start_dir)
        menus.mode = menus.DIR 
        menus.draw()
        
        '--- 1st SD read -----------------------------
        dirs_cache.init_clear()
        VOID files_folders.load_dirs(8, "*", 0)   '--- 0 = ROOT level
        dirs_cache.draw_dirs_2_scrn()
        read_files(8, "*.*", "/")                 '--- / = ROOT level
        select_focus2()
        '--------------------------------------------
        custom_keyboard_handler_on_off(TRUE)    '--- set custom KB handler ==> sub &kb_handler
        '---------------------------------------------
        '--- Main key loop!  
        '---------------------------------------------
        main_key_loop()
        '---------------------------------------------
        '--- !!!! End, lets bail from here !!!!
        '---------------------------------------------
        custom_keyboard_handler_on_off(FALSE)       '--- restore old KB handler
        txt.iso_off()
        'txt.uppercase()
        txt.clear_screen()
        txt.print("bye!")
        '--- restore the startup dir: TODO, ALT-Q, i think exits to current dir, Q exits startup
        diskio.chdir(start_dir) 
        RETURN

    END SUB    

    '=========================================================================

    SUB update_stats()
        dirs_cache.print_stats()
        files_cache.print_stats()
        update_stats_main()
    END SUB

    SUB update_stats_main() 
    END SUB

    '=========================================================================
    
    SUB read_files(drv AS UBYTE, filter AS STRING, path AS STRING)
        diskio.chdir(path)
        files_cache.init_clear()
        VOID files_folders.load_files(drv, filter)        '--- clears & reads files into files_cache
        files_cache.draw_files_2_scrn(0)
    END SUB
        
    '=========================================================================

    SUB select_focus2()
        IF menus.mode = menus.FILE THEN
            dirs_cache.lost_focus()
            files_cache.set_focus()
        ELSE
            dirs_cache.set_focus()
            files_cache.lost_focus()
        END IF
        menus.draw()
        update_stats()
    END SUB

    SUB select_focus()

        IF menus.mode = menus.DIR AND (NOT dirs_cache.current.logged) THEN
            '--- loads pointed dir files into file panel but NO focus
            dirs_cache.current.logged = TRUE
            ALIAS spath = g_tmp_str_buffer1
            strings_ext.concat_strings("/", dirs_cache.current.name, spath)
            read_files(diskio.drivenumber, files_folders.filter_files, spath)
            files_cache.lost_focus()
            files_cache.print_stats()
            RETURN
        END IF
        menus.mode = IIF menus.mode = menus.FILE THEN menus.DIR ELSE menus.FILE
        select_focus2()
    END SUB

    '=========================================================================
    '=========================================================================
    '=========================================================================
    
    '--- main character input loop       
    SUB main_key_loop()
        REPEAT

            IF NOT menus.CTRL_PRESSED AND (NOT menus.ALT_PRESSED) THEN 
                menus.clear_modifier_flags() 
            END IF
            

            IF (NOT menus.is_dir_menu) AND (NOT menus.is_file_menu) OR menus.is_prompt THEN
                '--- what menu is visible? draw base menu
                IF (NOT menus.CTRL_PRESSED AND NOT menus.ALT_PRESSED) OR 
                        (NOT menus.is_alt_dir_menu AND NOT menus.is_alt_file_menu AND 
                        NOT menus.is_ctrl_dir_menu AND NOT menus.is_ctrl_file_menu) THEN 
                    menus.draw() '--- draw non ALT / CTRL menu
                    CONTINUE
                END IF
            END IF
            
            
            '--- check modifer keys, draw ALT / CTRL menu or process a key
            IF menus.ALT_PRESSED OR menus.CTRL_PRESSED THEN
                IF menus.is_alt_dir_menu OR menus.is_alt_file_menu OR menus.is_ctrl_dir_menu OR menus.is_ctrl_file_menu THEN 
                    IF keycode <> 0 OR keycode_ext <> 0 THEN process_keys.letter_keys()       '--- process modifer + key 
                    CONTINUE                                                            '--- menu is already shown, back to grab keys
                END IF 
                menus.draw()                                                            '--- draw CTRL / ALT menus
                CONTINUE
            END IF

            
            '----------------
            get_key_again:
            '----------------
            'keycode_ext = keycode = 0               '--- reset key vars, keycode_ext var contains modifer key
            VOID, keycode = cbm.GETIN()              '--- custom KB handler points to ==> &kb_handler
            'keycode = cx16.kbdbuf_get()
            IF keycode = 0 AND keycode_ext = 0 THEN GOTO get_key_again
        
            
            IF NOT menus.CTRL_PRESSED AND NOT menus.ALT_PRESSED THEN
                '--- key strokes - movement up / down / pgup / pgdn
                'debug.say2("keycode:",keycode)
                'sys.wait(200)
                SELECT CASE keycode
                    CASE keys.CR, keys.TAB '--- swap FILE / DIR focus
                        select_focus()
                    CASE keys.DN_ARROW_PRESSED
                        IF menus.mode = menus.DIR THEN 
                            IF dirs_cache.num_dirs <= 1 THEN CONTINUE
                            dirs_cache.key_down()  
                        ELSE
                            IF files_cache.num_files = 0 THEN CONTINUE
                            files_cache.key_down() 
                        END IF 
                        CONTINUE
                    CASE keys.UP_ARROW_PRESSED
                        IF menus.mode = menus.DIR THEN 
                            IF dirs_cache.num_dirs <= 1 THEN CONTINUE
                            dirs_cache.key_up()  
                        ELSE
                            IF files_cache.num_files = 0 THEN CONTINUE
                            files_cache.key_up() 
                        END IF 
                        CONTINUE
                    CASE keys.PAGE_DN_PRESSED
                        ' IF menus.mode = menus.DIR THEN 
                        '     'dirs_cache.key_up()  
                        ' ELSE
                        '     IF files_cache.num_files = 0 THEN CONTINUE
                        '     files_cache.key_up() 
                        ' END IF 
                        ' CONTINUE
                    CASE keys.PAGE_UP_PRESSED
                        ' IF menus.mode = menus.DIR THEN 
                        '     'dirs_cache.key_up()  
                        ' ELSE
                        '    IF files_cache.num_files = 0 THEN CONTINUE
                        '     files_cache.key_up() 
                        ' END IF 
                        '  CONTINUE
                END SELECT
            END IF
            
            IF keycode = 0 THEN CONTINUE
            process_keys.letter_keys()           '--- process keys
            IF flags.exit_out THEN BREAK         '--- break out of loop
            
        END REPEAT 
    END SUB

   
    '--------------------------------------------------------------------------
    '----------- KB handler stuff ---------------------------------------------
    '--------------------------------------------------------------------------

    SUB clear_kb()
        cx16.kbdbuf_clear() '--- clear the kb buffer
        FOR i = 0 TO 4   '--- clear the kb modifer queue
            last_keys[i] = 0    
        NEXT
    END SUB

    SUB custom_keyboard_handler_on_off(turn_on AS BOOL)
        IF turn_on THEN
            sys.set_irqd()
            old_keyhdl = cx16.KEYHDL
            cx16.KEYHDL = &kb_handler
            sys.clear_irqd()  
        ELSE
            sys.set_irqd()
            cx16.KEYHDL = old_keyhdl
            sys.clear_irqd()
        END IF
    END SUB

    FUNCTION kb_handler(keynum AS UBYTE) AS UBYTE
        ' NOTE: this handler routine expects the keynum in A and return value in A
        '       which is thankfully how prog8 translates this subroutine's calling convention.
        ' NOTE: it may be better to store the keynum somewhere else and let the main program
        '       loop figure out what to do with it, rather than putting it all in the handler routine

        'debug.say2("keyhandler:",keynum)

        '--- check CTRL / ALT key and set flag
        SELECT CASE keynum 
            CASE keys.EXT_CTRL_UP
                menus.CTRL_PRESSED = FALSE 
            CASE keys.EXT_CTRL_DN
                menus.CTRL_PRESSED = TRUE  
            CASE keys.EXT_ALT_UP
                menus.ALT_PRESSED = FALSE 
            CASE keys.EXT_ALT_DN
                menus.ALT_PRESSED = TRUE
        END SELECT  

        '--- save the last 5 keycodes because...
        '--- ALT-Q (or modifyer and key) is 4 bytes --> (ALT up and down) and (Q up and down)
        '--- 4 bytes! ;) and a 5th just for fun!
        IF kb_ndx = 5 THEN kb_ndx = 0
        last_keys[kb_ndx] = keynum
        kb_ndx++

        keycode_ext = keynum
        RETURN keynum           '--- is not returning ALT / CTRL codes

        ' '--- By returning 0 (in A) we will eat this key event. 
        ' '--- Return the original keynum value to pass it through.
        ' RETURN 0        
    END FUNCTION
END MODULE
