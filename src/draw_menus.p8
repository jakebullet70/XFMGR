
menus {
    const ubyte DIR  = 0
    const ubyte ALT  = 1
    const ubyte FILE = 2
    const ubyte CTRL = 3
    ubyte mode

    sub draw_menu_type(str tmp1) {
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
        helpers.print_strXY2(1,txt.height() - 4," " * 78)
        helpers.print_strXY2(1,txt.height() - 3," " * 78)
        helpers.print_strXY2(1,txt.height() - 2," " * 78)
        helpers.print_strXY2(1,txt.height() - 4,tmp1)
        helpers.print_strXY2(1,txt.height() - 3,cp437:"COMMANDS")
    }



    sub draw() {
        ;ubyte[] hkey_color = [1,1,2,2,3,4,5,99]
        when mode 
        {
            DIR ->  { 
                draw_menu_type(cp437:"DIR") 
                helpers.print_strXY2(1,txt.height()-2,cp437:"File")
                show_command_enter()
                ;--- 1st line
                helpers.print_strXY2(12,txt.height()-4,cp437:"Avail  Delete  Filespec  Log  Make")
                highlight_menu_keys([12,19,27,37,42],4,txt.height()-4,clr.MENU_BRIGHT)
                ;--- line2 
                helpers.print_strXY2(12,txt.height()-3,cp437:"Rename  Tag  Untag  Quit")
                highlight_menu_keys([12,20,25,32],3,txt.height()-3,clr.MENU_BRIGHT)
                
            } 
            FILE -> { 
                draw_menu_type(cp437:"FILE")
                helpers.print_strXY2(1,txt.height()-2,cp437:"Dir")
                show_command_enter()
                ;--- 1st line
                helpers.print_strXY2(12,txt.height()-4,cp437:"Copy  Delete  Edit  Filespec  Log  Move")
                highlight_menu_keys([12,18,26,32,42,47],5,txt.height()-4,clr.MENU_BRIGHT)
                ;--- line2 
                helpers.print_strXY2(12,txt.height()-3,cp437:"New date  Print  Rename  Tag  Untag  View  eXicute  Quit")
                highlight_menu_keys([12,22,29,37,42,49,56,64],7,txt.height()-3,clr.MENU_BRIGHT)
            } 
            ALT ->  { draw_menu_type(cp437:"ALT") } 
            CTRL -> { draw_menu_type(cp437:"CTRL")} 
        }
    }

    sub show_command_enter() {
        helpers.print_strXY(6,txt.height()-2,cp437:"◄╛",clr.MENU_BRIGHT,false)
        txt.color2(clr.MENU_NORMAL & 15, clr.MENU_NORMAL>>4)
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
