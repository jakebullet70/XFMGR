%import diskio
%import textio
%import strings
%import syslib  
;--- code modules
%import helpers
%import files_folders
%import linked_list_dir
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
    const ubyte MENU_NORMAL = $b1  ;
    const ubyte MENU_BRIGHT = $b7  ; 
    const ubyte ROW_HILIGHT = $1e
    const ubyte BOXES = $be ;
}

main {
    ;--- tmp vars to be used wherever
    str g_tmp_str_buffer1 = "?" * 255
    str g_tmp_str_buffer2 = "?" * 255
    str g_tmp_str_buffer3 = "?" * 255
    ubyte i,j,x,y = 0
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
        menus.draw()

        debug.init(0)
        debug.say("debug inited!")

        dir_cache.init()
        void files_folders.read(8)      ;--- read files into dir_cache
        dir_cache.draw_files_2_scrn()

    ;--- main character input loop       
    char_loop:
        ubyte char
        void, char = cbm.GETIN()
        if char == 0 { goto char_loop }

        when char {
            27  -> { goto end_me }  ; ESC key to end program
            17  -> { dir_cache.key_down() }
            145 -> { dir_cache.key_up() }

        }

        goto char_loop

    end_me:
        ;txt.color2(0,3)
        ;txt.color2(colors & 15, colors>>4)
        txt.iso_off()
        txt.uppercase()
        txt.clear_screen()
        txt.print("BYE!")
        return

    }

}
