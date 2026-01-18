
menus {
    const ubyte DIR  = 0
    const ubyte FILE = 1
    ubyte mode ;= TODO rename var to view_mode

    ;const str CR_ICON = cp437:"◄╛"

    bool CTRL_PRESSED, ALT_PRESSED = false
    bool is_ctrl_dir_menu,is_alt_dir_menu,is_ctrl_file_menu,is_alt_file_menu = false
    bool is_dir_menu, is_file_menu, is_prompt = false

    
    sub highlight_menu_keys(ubyte[] cols,ubyte alen, ubyte row, ubyte ccolor) {
        alias i = main.i
        for i in 0 to alen {
            txt.setclr(cols[i],row,ccolor) 
        }
    }

    sub clear_menu_area() {
        alias j = main.j
        txt.color2(theme.MENU_NORMAL & 15, theme.MENU_NORMAL>>4)
        for j in 4 downto 2 { 
            helpers.print_strXY2(1,txt.height() - j," " * 78)
        }
    }

    sub show_menu_header(str mtype,str DIRorFILE) {
        clear_menu_area()
        helpers.print_strXY2(1,txt.height() - 4,mtype)
        helpers.print_strXY2(1,txt.height() - 3,cp437:"COMMANDS")
        helpers.print_strXY2(1,txt.height() - 2,DIRorFILE)
        helpers.print_strXY(6,txt.height()  - 2,cp437:"◄╛",theme.MENU_BRIGHT,false)
        txt.color2(theme.MENU_NORMAL & 15, theme.MENU_NORMAL>>4)
    }

    sub clear_modifier_flags() {
        is_ctrl_dir_menu = is_alt_dir_menu = is_ctrl_file_menu = is_alt_file_menu  = false
    }

    sub draw() {
        ;debug.say2("modifer_key:",modifer_key)
        ;bool is_ctrl_dir_menu,is_alt_dir_menu,is_ctrl_file_menu,is_alt_file_menu = false
        is_prompt = false
        when mode 
        {
            DIR ->  {
                
                if not ALT_PRESSED and not CTRL_PRESSED {
                    clear_modifier_flags()
                    is_dir_menu = true
                    is_file_menu = false
                    show_menu_header(cp437:"DIR",cp437:"File")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Avail  Delete  Filespec  Log  Make")
                    highlight_menu_keys([12,19,27,37,42],4,txt.height()-4,theme.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Rename  Tag  Untag  Quit")
                    highlight_menu_keys([12,20,25,32],3,txt.height()-3,theme.MENU_BRIGHT)

                } else if ALT_PRESSED {
                    is_alt_dir_menu = true
                    is_dir_menu = is_file_menu = false
                    show_menu_header(cp437:"ALT DIR",cp437:"File")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Edit  Graft  Log  Prune")
                    highlight_menu_keys([12,18,25,30],3,txt.height()-4,theme.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Tag  Untag  Quit")
                    highlight_menu_keys([12,17,24],2,txt.height()-3,theme.MENU_BRIGHT)       

                } else if CTRL_PRESSED {
                    is_ctrl_dir_menu = true
                    is_dir_menu = is_file_menu = false
                    show_menu_header(cp437:"CTRL DIR",cp437:"File")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Log  Tag  Untag")
                    highlight_menu_keys([12,17,22],2,txt.height()-4,theme.MENU_BRIGHT)
                } 
            } 

            FILE -> { 
                if not ALT_PRESSED and not CTRL_PRESSED {
                    clear_modifier_flags()
                    is_dir_menu = false
                    is_file_menu = true
                    show_menu_header(cp437:"FILE",cp437:"Dir")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Copy  Delete  Edit  Filespec  Log  Move")
                    highlight_menu_keys([12,18,26,32,42,47],5,txt.height()-4,theme.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"New date  Print  Rename  Tag  Untag  View  eXecute  Quit")
                    highlight_menu_keys([12,22,29,37,42,49,56,64],7,txt.height()-3,theme.MENU_BRIGHT) 

                } else if ALT_PRESSED {
                    is_alt_file_menu = true
                    is_dir_menu = is_file_menu = false
                    show_menu_header(cp437:"ALT FILE",cp437:"Dir")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Copy  Log  Move")
                    highlight_menu_keys([12,18,23],2,txt.height()-4,theme.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Tag  Untag  Quit")
                    highlight_menu_keys([12,17,24],2,txt.height()-3,theme.MENU_BRIGHT)

                } else if CTRL_PRESSED {
                    is_ctrl_file_menu = true
                    is_dir_menu = is_file_menu = false
                    show_menu_header(cp437:"CTRL FILE",cp437:"Dir")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Copy  Delete  Log  Move  New date  Print")
                    highlight_menu_keys([12,18,26,31,37,47],5,txt.height()-4,theme.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Rename  Search  Tag  Untag  View")
                    highlight_menu_keys([12,20,28,33,40],4,txt.height()-3,theme.MENU_BRIGHT)

                }              
            } 
        }
    }
}