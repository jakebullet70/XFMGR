
;--- misc functions
helpers {
    ubyte chr_topleft, chr_topright, chr_botleft, chr_botright
    ubyte chr_tleft, chr_tright, chr_tup, chr_tdown, chr_horiz, chr_vert
    

    sub print_strXY(ubyte col, ubyte row, str txtstring, ubyte colors, bool convertchars) {
        txt.plot(col,row)
        txt.color2(colors & 15, colors>>4)
        txt.print_lit(txtstring)
        ;--- convertchars NOT BEING USED    
    }

    sub print_strXY2(ubyte col, ubyte row, str txtstring) {
        txt.plot(col,row)
        txt.print_lit(txtstring)
    }

    sub plot_charXY(ubyte col, ubyte row, ubyte char, ubyte colors) {
        txt.setcc2(col,row,char,colors)
    }  

    sub draw_box(ubyte col, ubyte row, ubyte width, ubyte height, ubyte colors) {
        alias rows = main.j     ;--- re-use vars
        alias i    = main.i        ;--- re-use vars
        rows = txt.height()
        pokew(903,65) ;--- change scrn height so no scroll  

        draw_horiz_line(col,row,width)
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
        
        draw_horiz_line(col,row+height-1,width)
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
        draw_box(0,0,txt.width(), txt.height(), theme.BOXES)
        draw_horiz_line(0,txt.height() - 5,txt.width())
        draw_horiz_line(0,2,txt.width())
        draw_horiz_line(0,4,txt.width())
        draw_vert_line(30,4,txt.height()-5)
        plot_charXY(30,4,chr_tdown,theme.BOXES)
        plot_charXY(30,txt.height()-5,chr_tup,theme.BOXES)
        
        print_strXY(1 ,1,iso:"XFMGR V0.1.0",theme.TXT_NORMAL,false)
        print_strXY(63,1,iso:"Dec 29 - 02:30PM",theme.TXT_NORMAL,false)
        print_strXY(1 ,3,iso:"Path",theme.TXT_NORMAL,false)
        print_strXY(32,3,iso:"Files",theme.TXT_NORMAL,false)
}

    sub draw_horiz_line(ubyte col,ubyte row, ubyte width){
        txt.plot(col,row)
        txt.color2(theme.BOXES & 15, theme.BOXES>>4)
        repeat width {txt.chrout_lit(chr_horiz)}
        plot_charXY(col,row,chr_tleft,theme.BOXES)
        plot_charXY(col+width-1,row,chr_tright,theme.BOXES)
    }

    sub draw_vert_line(ubyte col,ubyte row, ubyte height){
        alias i    = main.i        ;--- re-use vars
        for i in 1 to height - 2 {
             txt.plot(col,row+i)
             txt.chrout_lit(chr_vert)
        }
    }


    sub edit_file(uword filename) {
        ; activate rom based x16edit, see https://github.com/stefan-b-jakobsson/x16-edit/tree/master/docs
        main.custom_keyboard_handler_on_off(false)

        ubyte x16edit_bank = cx16.search_x16edit()
        if x16edit_bank<255 {
            sys.enable_caseswitch()     ; workaround for character set issue in X16Edit 0.7.1
            ubyte filename_length = 0
            if filename!=0
                filename_length = strings.length(filename)
            ubyte old_bank = cx16.getrombank()
            cx16.rombank(x16edit_bank)
            cx16.x16edit_loadfile_options(1, 255, filename,
                mkword(%00000011, filename_length),         ; auto-indent and word-wrap enable
                mkword(80, 4),          ; wrap and tabstop
                mkword(theme.X16EDITOR_NORMAL, diskio.drivenumber),
                mkword(theme.X16EDITOR_HEADER,theme.X16EDITOR_STATUS))
                ;mkword(background_color<<4 | text_color, diskio.drivenumber),
                ;mkword(0,0))
            cx16.rombank(old_bank)
            sys.disable_caseswitch()
        } else {
            ;err.print("error: no x16edit found in rom")
            ;sys.wait(180)
            ;return false
        }
        main.custom_keyboard_handler_on_off(true)
    }



    sub run_file() {
        ; CLS : LOCATE 10,1 : PRINT : PRINT "STARTING BASLOAD..."
        ; PRINT "BASLOAD";CHR$(34) + FILE_TO_COMP$ + CHR$(34) + "{UP}{UP}";:
        ; KBBUFFER_OUT = $FEC3 : A.REG = 780
        ; POKE A.REG,13       : SYS KBBUFFER_OUT
        ; POKE A.REG,ASC("R") : SYS KBBUFFER_OUT
        ; POKE A.REG,ASC("U") : SYS KBBUFFER_OUT
        ; POKE A.REG,ASC("N") : SYS KBBUFFER_OUT
        ; POKE A.REG,ASC(":") : SYS KBBUFFER_OUT
        ; POKE A.REG,13       : SYS KBBUFFER_OUT

        ; txt.clear_screen()
        ; txt.plot(0,10)
        ; txt.ptint("load")
        ; txt.print()
        ; txt.print(flags.run_at_exit_str)
    }

}
