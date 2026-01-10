
menus {
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
        when mode 
        {
            DIR ->  { draw_menu_type(cp437:"DIR") } 
            FILE -> { draw_menu_type(cp437:"FILE")} 
            ALT ->  { draw_menu_type(cp437:"ALT") } 
            CTRL -> { draw_menu_type(cp437:"CTRL")} 
        }
    }
}
