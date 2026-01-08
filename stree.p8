%import diskio
%import textio
%import strings
%import syslib  
;--- code modules
%import linked_list_dir
%import helpers
%import files_folders
;---
;%encoding "petscii"
%option no_sysinit
%zeropage basicsafe


clr {
    ;--- default colors
    const ubyte TXT_NORMAL = $b1  ; 
    const ubyte TXT_BRIGHT = $b1  ; 
    const ubyte MENU_NORMAL = $b1  ;
    const ubyte MENU_BRIGHT = $b7  ; 
    const ubyte BOXES = $be ;
}

menu_modes {
    const ubyte DIR  = 0
    const ubyte ALT  = 1
    const ubyte FILE = 2
    const ubyte CTRL = 3
    ubyte mode

    sub draw_menu_type(str tmp1) {
        helpers.print_strXY(1,txt.height() - 4," " * 78,clr.MENU_NORMAL,false)
        helpers.print_strXY(1,txt.height() - 3," " * 78,clr.MENU_NORMAL,false)
        helpers.print_strXY(1,txt.height() - 2," " * 78,clr.MENU_NORMAL,false)
        helpers.print_strXY(1,txt.height() - 4,tmp1,clr.MENU_NORMAL,false)
        helpers.print_strXY(1,txt.height() - 3,cp437:"COMMANDS",clr.MENU_NORMAL,false)
    }

    sub draw() {
        when mode {
            DIR ->  { draw_menu_type(cp437:"DIR") } 
            FILE -> { draw_menu_type(cp437:"FILE")} 
            ALT ->  { draw_menu_type(cp437:"ALT") } 
            CTRL -> { draw_menu_type(cp437:"CTRL")} 
        }
    }
}

main {
    ;--- tmp vars to be used wherever
    str g_tmp_str_buffer1 = "?" * 80
    str g_tmp_str_buffer2 = "?" * 255
    ubyte i,j = 0
    bool bool_tmp = false

    sub start() {

        cx16.set_screen_mode(0)
        txt.color2(clr.TXT_NORMAL & 15, clr.TXT_NORMAL>>4)
        txt.clear_screen()        
        
        txt.cp437()                     ;--- enable ISO character set 
        txt.lowercase()
        helpers.set_characters(true)    ;--- use ISO characters for box drawing
        helpers.draw_main_scrn()

        menu_modes.mode = menu_modes.DIR ;--- default for the moment
        menu_modes.draw()

        dir_cache.init()
        void files_folders.read(8)
        ;txt.plot(4,4)
        ;dir_cache.print_forward()

    ;--- main character input loop       
    char_loop:
        ubyte char
        void, char = cbm.GETIN()
        if char == 0
            goto char_loop

        when char {
            27 -> { goto end_me }  ; ESC key to end program

        }

        goto char_loop

    end_me:
        txt.uppercase()
        txt.color2(0,3)
        ;txt.color2(colors & 15, colors>>4)
        txt.print("BYE!")
        return

    }

}

list {
    ubyte page_height = 50
    alias total_dir   = files_folders.total_dir
    alias total_files = files_folders.total_files
    const bool FILE_NAME_SIZE = 42
    const bool DIR_ENTRY = true
    const bool FILE_ENTRY = false
    const bool NOT_TAGGED = false


    sub pretty_line(str line) {
        ;--- make each file name pretty

    }


}


