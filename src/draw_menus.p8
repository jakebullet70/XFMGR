
menus {
    const ubyte DIR  = 0
    const ubyte ALT_PRESSED  = 2
    const ubyte FILE = 1
    const ubyte CTRL_PRESSED = 4
    ubyte mode
    bool is_ctrl_dir_menu,is_alt_dir_menu,is_ctrl_file_menu,is_alt_file_menu = false

    sub clear_menu_area() {
        alias j = main.j
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
        for j in 4 downto 2 {
            helpers.print_strXY2(1,txt.height() - j," " * 78)
        }
    }

    sub show_menu_header(str mtype,str DIRorFILE) {
        clear_menu_area()
        helpers.print_strXY2(1,txt.height() - 4,mtype)
        helpers.print_strXY2(1,txt.height() - 3,cp437:"COMMANDS")
        helpers.print_strXY2(1,txt.height()-2,DIRorFILE)
        helpers.print_strXY(6,txt.height()-2,cp437:"◄╛",clr.MENU_BRIGHT,false)
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
    }

    sub clear_modifier_flags(){
        is_ctrl_dir_menu  = false
        is_alt_dir_menu   = false
        is_ctrl_file_menu = false
        is_alt_file_menu  = false
    }

    sub draw(ubyte modifer_key) {
        ;debug.say2("modifer_key:",modifer_key)
        when mode 
        {
            DIR ->  { 
                if modifer_key == 0 {
                    clear_modifier_flags()
                    show_menu_header(cp437:"DIR",cp437:"File")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Avail  Delete  Filespec  Log  Make")
                    highlight_menu_keys([12,19,27,37,42],4,txt.height()-4,clr.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Rename  Tag  Untag  Quit")
                    highlight_menu_keys([12,20,25,32],3,txt.height()-3,clr.MENU_BRIGHT)

                } else if modifer_key == ALT_PRESSED {
                    is_alt_dir_menu = true
                    show_menu_header(cp437:"ALT DIR",cp437:"File")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Edit  Graft  Log  Prune")
                    highlight_menu_keys([12,18,25,30],3,txt.height()-4,clr.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Tag  Untag  Quit")
                    highlight_menu_keys([12,17,24],2,txt.height()-3,clr.MENU_BRIGHT)
                   

                } else if modifer_key == CTRL_PRESSED {
                    is_ctrl_dir_menu = true
                    show_menu_header(cp437:"CTRL DIR",cp437:"File")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Log  Tag  Untag")
                    highlight_menu_keys([12,17,22],2,txt.height()-4,clr.MENU_BRIGHT)
                }
                
            } 
            FILE -> { 
                if modifer_key == 0 {
                    clear_modifier_flags()
                    show_menu_header(cp437:"FILE",cp437:"Dir")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Copy  Delete  Edit  Filespec  Log  Move")
                    highlight_menu_keys([12,18,26,32,42,47],5,txt.height()-4,clr.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"New date  Print  Rename  Tag  Untag  View  eXicute  Quit")
                    highlight_menu_keys([12,22,29,37,42,49,56,64],7,txt.height()-3,clr.MENU_BRIGHT) 

                } else if modifer_key == ALT_PRESSED {
                    is_alt_file_menu = true
                    show_menu_header(cp437:"ALT FILE",cp437:"Dir")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Copy  Log  Move")
                    highlight_menu_keys([12,18,23],2,txt.height()-4,clr.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Tag  Untag  Quit")
                    highlight_menu_keys([12,17,24],2,txt.height()-3,clr.MENU_BRIGHT)


                } else if modifer_key == CTRL_PRESSED {
                    is_ctrl_file_menu = true
                    show_menu_header(cp437:"CTRL FILE",cp437:"Dir")
                    ;--- 1st line
                    helpers.print_strXY2(12,txt.height()-4,cp437:"Copy  Delete  Log  Move  New date  Print")
                    highlight_menu_keys([12,18,26,31,37,47],5,txt.height()-4,clr.MENU_BRIGHT)
                    ;--- line2 
                    helpers.print_strXY2(12,txt.height()-3,cp437:"Rename  Search  Tag  Untag  View")
                    highlight_menu_keys([12,20,28,33,40],4,txt.height()-3,clr.MENU_BRIGHT)

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
