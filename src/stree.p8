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
%import draw_menus
%import debug
;---
;%encoding "petscii"
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

    sub start() {

        cx16.set_screen_mode(0)
        txt.color2(clr.TXT_NORMAL & 15, clr.TXT_NORMAL>>4)
        txt.clear_screen()        
        
        txt.cp437()                     ;--- enable ISO character set 
        txt.lowercase()
        helpers.set_characters(true)    ;--- use ISO characters for box drawing
        helpers.draw_main_scrn()

        menus.mode = menus.DIR ;--- default for the moment
        menus.draw(0)

        debug.init(0)
        ;debug.say("debug inited!")

        files_cache.init()
        dirs_cache.init()

        ;void files_folders.read_dirs(8)      ;--- read files into files_cache
        ;files_cache.draw_files_2_scrn()
        void files_folders.read_files(8)      ;--- read files into files_cache
        files_cache.draw_files_2_scrn()

    ;--- main character input loop       
    char_loop:
        ubyte char,mkey
        char = cbm.GETIN2()
        mkey = cx16.kbdbuf_get_modifiers() 
        if (menus.is_alt_dir_menu or menus.is_alt_file_menu or 
            menus.is_ctrl_dir_menu or menus.is_ctrl_file_menu) and mkey == 0 { menus.draw(0) }
        ;debug.say2("mkey:",mkey)
        if char == 0 and mkey == 0 { goto char_loop }


        ;--- modifer keys
        if mkey == menus.ALT_PRESSED or mkey == menus.CTRL_PRESSED {
            if menus.is_alt_dir_menu or menus.is_alt_file_menu or menus.is_ctrl_dir_menu or menus.is_ctrl_file_menu { 
                goto char_loop ;--- menu is already shown
            } 
            menus.draw(mkey)
        }
    

        ;--- key strokes
        when char {
            27  -> { goto end_me }  ; ESC key to end program
            17  -> { 
                when menus.mode {
                    ;menus.DIR ->  {  } 
                    menus.FILE -> { files_cache.key_down() } 
                } 
            }
            145 -> { 
                when menus.mode {
                    ;DIR ->  {  } 
                    menus.FILE -> { files_cache.key_up() } 
                }
            }
            51  -> { 
                when menus.mode {
                    ;DIR ->  {  } 
                    menus.FILE -> { files_cache.key_page_down() } 
                }
            }    
            57  -> {
                when menus.mode {
                    ;DIR ->  {  } 
                    menus.FILE -> { files_cache.key_page_up() } 
                }
            } 
        
;            'a' to 'z' -> { }

        }
        ;debug.say2("key:",char)
        goto char_loop

    end_me:
        txt.iso_off()
        txt.uppercase()
        txt.clear_screen()
        txt.print("BYE!")
        return

    }

}
