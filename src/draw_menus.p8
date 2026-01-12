
menus {
    const ubyte DIR  = 0
    const ubyte ALT_PRESSED  = 4
    const ubyte FILE = 1
    const ubyte CTRL_PRESSED = 2
    ubyte mode
    bool is_ctrl_dir_menu,is_alt_dir_menu,is_ctrl_file_menu,is_alt_file_menu = false

    
    sub show_command_enter(str mtype,str DIRorFILE) {
        ;draw_menu_type(mtype)
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
        helpers.print_strXY2(1,txt.height() - 4," " * 78)
        helpers.print_strXY2(1,txt.height() - 3," " * 78)
        helpers.print_strXY2(1,txt.height() - 2," " * 78)
        helpers.print_strXY2(1,txt.height() - 4,mtype)
        helpers.print_strXY2(1,txt.height() - 3,cp437:"COMMANDS")

        helpers.print_strXY2(1,txt.height()-2,DIRorFILE)
        helpers.print_strXY(6,txt.height()-2,cp437:"◄╛",clr.MENU_BRIGHT,false)
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
    }

    sub clear_modifier_flags(){
        is_ctrl_dir_menu = false
        is_alt_dir_menu = false
        is_ctrl_file_menu = false
        is_alt_file_menu = false
    }

    sub draw(ubyte modifer_key) {
        ;debug.say2("modifer_key:",modifer_key)
        when mode 
        {
            DIR ->  { 
                if modifer_key == 0 {
                    clear_modifier_flags()
                    show_command_enter(cp437:"DIR",cp437:"File")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Avail  Delete  Filespec  Log  Make")
                    highlight_menu_keys([12,19,27,37,42],4,txt.height()-4,clr.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Rename  Tag  Untag  Quit")
                    highlight_menu_keys([12,20,25,32],3,txt.height()-3,clr.MENU_BRIGHT)

                } else if modifer_key == ALT_PRESSED {
                    is_alt_dir_menu = true
                    show_command_enter(cp437:"ALT DIR",cp437:"File")

                } else if modifer_key == CTRL_PRESSED {
                    is_ctrl_dir_menu = true
                    show_command_enter(cp437:"CTRL DIR",cp437:"File")
                }
                
            } 
            FILE -> { 
                if modifer_key == 0 {
                    clear_modifier_flags()
                    show_command_enter(cp437:"FILE",cp437:"Dir")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Copy  Delete  Edit  Filespec  Log  Move")
                    highlight_menu_keys([12,18,26,32,42,47],5,txt.height()-4,clr.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"New date  Print  Rename  Tag  Untag  View  eXicute  Quit")
                    highlight_menu_keys([12,22,29,37,42,49,56,64],7,txt.height()-3,clr.MENU_BRIGHT) 

                } else if modifer_key == ALT_PRESSED {
                    is_alt_file_menu = true
                    show_command_enter(cp437:"ALT FILE",cp437:"Dir")
                    

                } else if modifer_key == CTRL_PRESSED {
                    is_ctrl_file_menu = true
                    show_command_enter(cp437:"CTRL FILE",cp437:"Dir")
                }
              
            } 

            ;ALT ->  { draw_menu_type(cp437:"ALT") } 
            ;CTRL -> { draw_menu_type(cp437:"CTRL")} 
        }
    }


  
    sub highlight_menu_keys(ubyte[] cols,ubyte alen, ubyte row, ubyte ccolor) {
        alias i = main.i
        for i in 0 to alen {
            txt.setclr(cols[i],row,ccolor)
        }
    }


    ;---------------------- KEY STROKES -------------------------------------
    ;---------------------- KEY STROKES -------------------------------------
    ;---------------------- KEY STROKES -------------------------------------
    

}
