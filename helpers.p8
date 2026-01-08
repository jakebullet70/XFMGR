
;--- misc functions
helpers {
    ubyte chr_topleft, chr_topright, chr_botleft, chr_botright
    ubyte chr_tleft, chr_tright, chr_tup, chr_tdown, chr_horiz, chr_vert

    sub print_strXY(ubyte col, ubyte row, str txtstring, ubyte colors, bool convertchars) {
        txt.plot(col,row)
        txt.color2(colors & 15, colors>>4)
        txt.print_lit(txtstring)
    }

    sub plot_charXY(ubyte col, ubyte row, ubyte char, ubyte colors) {
        txt.setcc2(col,row,char,colors)
    }  

    sub draw_box(ubyte col, ubyte row, ubyte width, ubyte height, ubyte colors) {

        alias i = main.i        ;--- re-use vars
        alias rows = main.j     ;--- re-use vars
        rows = txt.height()
        pokew(903,65) ;--- change scrn height so no scroll  

        draw_vert_line(col,row,width)
        txt.plot(col,row)
        txt.chrout_lit(chr_topleft)
        txt.plot(col+width-1,row)
        txt.chrout_lit(chr_topright)

        for i in 1 to height - 2 {
             txt.plot(col,row+i)
             txt.chrout_lit(chr_vert)
             txt.plot(col+width-1,row+i)
             txt.chrout_lit(chr_vert)
        }
        
        draw_vert_line(col,row+height-1,width)
        txt.plot(col,row+height-1)
        txt.chrout_lit(chr_botleft)
        txt.plot(col+width-1,row+height-1)
        txt.chrout_lit(chr_botright)
        pokew(903,rows)   ;--- restore screen height    
    }

    sub set_characters(bool iso_chars) {
        if iso_chars {
            chr_topleft = 218 
            chr_topright = 191
            chr_botleft = 192 
            chr_botright = 217 
            chr_vert = 179 
            chr_horiz = 196 
            chr_tleft = 195
            chr_tright = 180
            chr_tup = 193
            chr_tdown = 194
        } else {
            ; PETSCII box symbols
            chr_topleft = '┌'
            chr_topright = '┐'
            chr_botleft = '└'
            chr_botright = '┘'
            chr_horiz = '─'
            chr_vert = '│' 
            chr_tleft = '├'
            chr_tright = '┤'
        }
    }

    sub draw_main_scrn() {
        txt.clear_screen()
        draw_box(0,0,txt.width(), txt.height(), clr.BOXES)
        draw_vert_line(0,txt.height() - 5,80)
        draw_vert_line(0,2,80)
        draw_vert_line(0,4,80)
        print_strXY(1 ,1,iso:"XFMGR V0.1.0",clr.TXT_NORMAL,false)
        print_strXY(63,1,iso:"Dec 29 - 02:30PM",clr.TXT_NORMAL,false)
}

    sub draw_vert_line(ubyte col,ubyte row, ubyte width){
        txt.plot(col,row)
        txt.color2(clr.BOXES & 15, clr.BOXES>>4)
        repeat width {txt.chrout_lit(chr_horiz)}
        plot_charXY(col,row,chr_tleft,clr.BOXES)
        plot_charXY(col+width-1,row,chr_tright,clr.BOXES)
    }

}
