%import diskio
%import textio
%import strings
%import syslib  

;%encoding "petscii"
%import namesorting
%option no_sysinit
%zeropage basicsafe

; simple test program for the "VTUI" text user interface library
; see:  https://github.com/JimmyDansbo/VTUIlib

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
        helpers.print_strXY(1,txt.height() - 3,iso:"COMMANDS",clr.MENU_NORMAL,false)
    }

    sub draw(){
    ;''sub print_strXY(ubyte col, ubyte row, str txtstring, ubyte colors, bool convertchars) {'    
        when mode {
            DIR ->  { 
                ;void strings.copy("DIR1",main.g_tmp_str_buffer1)
                draw_menu_type(iso:"DIR")
            } 
            FILE -> { 
                draw_menu_type(iso:"FILE")

            } 
            ALT ->  { 
                draw_menu_type(iso:"ALT")
                
            } 
            CTRL -> { 
                draw_menu_type(iso:"CTRL")
            } 

        }



    }

}

main {
    str g_tmp_str_buffer1 = "?" * 80
    str g_tmp_str_buffer2 = "?" * 255

    sub start() {

        vtui.initialize()
        vtui.screen_set(0)              ; 80x60
        
        txt.cp437()                     ;--- enable ISO character set 
        txt.lowercase()
        helpers.set_characters(true)    ;--- use ISO characters for box drawing
        
        helpers.draw_main_scrn()

        ;helpers.print_strXY(32,10,sc:"Hello, world! vtui from Prog8!", clr.TXT_NORMAL, true)
        ;helpers.print_strXY(32,15,iso:"Hello, world! vtui from Prog8!", clr.TXT_BRIGHT, false)
        ;helpers.print_strXY(32,18,cp437:"Hello, world! vtui from Prog8!", clr.TXT_BRIGHT, false)

        menu_modes.mode = menu_modes.DIR ;--- default for the moment
        menu_modes.draw()




    ;--- main character input loop       
    char_loop:
        ubyte char
        void, char = cbm.GETIN()
        if char==0
            goto char_loop

        when char {
            27 -> { goto end_me }  ; ESC key to end program

        }

        goto char_loop

    end_me:
        txt.uppercase()
        return

    }

}


clr {
    ;--- default colors
    const ubyte TXT_NORMAL = $b1  ; 
    const ubyte TXT_BRIGHT = $b1  ; 
    const ubyte MENU_NORMAL = $b1  ;
    const ubyte MENU_BRIGHT = $b7  ; 
    const ubyte BOXES = $be ;
}

;--- misc functions
helpers {
    ubyte chr_topleft, chr_topright, chr_botleft, chr_botright, chr_horiz, chr_vert, chr_tleft, chr_tright, chr_tup, chr_tdown

    sub print_strXY(ubyte col, ubyte row, str txtstring, ubyte colors, bool convertchars) {
        vtui.gotoxy(col,row)
        vtui.print_str2(txtstring, colors, convertchars)
    }

    sub plot_charXY(ubyte col, ubyte row, ubyte char, ubyte colors) {
        vtui.gotoxy(col,row)
        vtui.plot_char(char, colors)
    }  

    sub draw_box(ubyte col, ubyte row, ubyte width, ubyte height, ubyte colors) {
        ;https://github.com/JimmyDansbo/VTUIlib?tab=readme-ov-file#function-name-border
        const ubyte boxMode = 6 ; 0-5 paints PETSCII box chars 
        cx16.r3L = chr_topright
        cx16.r3H = chr_topleft
        cx16.r4L = chr_botright
        cx16.r4H = chr_botleft
        cx16.r5L = chr_horiz
        cx16.r5H = cx16.r5L
        cx16.r6L = chr_vert
        cx16.r6H = cx16.r6L
        vtui.gotoxy(col,row)
        vtui.border(boxMode, width, height, colors)
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
        ;vtui.set_stride(2) ;--- disables color attributes in calls like border/fill_box etc.
        vtui.clr_scr(' ', clr.TXT_NORMAL)
        draw_box(0,0,txt.width(), txt.height(), clr.BOXES)
        draw_vert_line(0,txt.height() - 5,80)
        draw_vert_line(0,2,80)
        draw_vert_line(0,4,80)
        print_strXY(1 ,1,iso:"XFMGR V0.1.0",clr.TXT_NORMAL,false)
        print_strXY(63,1,iso:"Dec 29 - 02:30PM",clr.TXT_NORMAL,false)
        ;vtui.set_stride(1) ;--- back to normal
    }

    sub draw_vert_line(ubyte col,ubyte row, ubyte width){
        vtui.gotoxy(col,row)
        vtui.hline(chr_horiz,width,clr.BOXES)
        plot_charXY(col,row,chr_tleft,clr.BOXES)
        plot_charXY(width-1,row,chr_tright,clr.BOXES)
    }

}

;--- VTUI library interface
vtui $1000 {

    %option no_symbol_prefixing
    %asmbinary "VTUI1.2.BIN", 2     ; skip the 2 dummy load address bytes

    ; NOTE: base address $1000 here must be the same as the block's memory address, for obvious reasons!
    ; The routines below are for VTUI 1.0
    const uword vtjmp = $1002
    extsub vtjmp - 2   =  initialize() clobbers(A, X, Y)
    extsub vtjmp + 0*3 =  screen_set(ubyte mode @A) clobbers(A, X, Y)
    extsub vtjmp + 1*3  =  set_bank(bool bank1 @Pc) clobbers(A)
    extsub vtjmp + 2*3  =  set_stride(ubyte stride @A) clobbers(A)
    extsub vtjmp + 3*3  =  set_decr(bool incrdecr @Pc) clobbers(A)
    extsub vtjmp + 4*3  =  clr_scr(ubyte char @A, ubyte colors @X) clobbers(Y)
    extsub vtjmp + 5*3  =  gotoxy(ubyte column @A, ubyte row @Y)
    extsub vtjmp + 6*3  =  plot_char(ubyte char @A, ubyte colors @X)
    extsub vtjmp + 7*3  =  scan_char() -> ubyte @A, ubyte @X
    extsub vtjmp + 8*3  =  hline(ubyte char @A, ubyte length @Y, ubyte colors @X) clobbers(A)
    extsub vtjmp + 9*3  =  vline(ubyte char @A, ubyte height @Y, ubyte colors @X) clobbers(A)
    extsub vtjmp + 10*3 =  print_str(str txtstring @R0, ubyte length @Y, ubyte colors @X, ubyte convertchars @A) clobbers(A, Y)
    extsub vtjmp + 11*3 =  fill_box(ubyte char @A, ubyte width @R1, ubyte height @R2, ubyte colors @X) clobbers(A, Y)
    extsub vtjmp + 12*3 =  pet2scr(ubyte char @A) -> ubyte @A
    extsub vtjmp + 13*3 =  scr2pet(ubyte char @A) -> ubyte @A
    extsub vtjmp + 14*3 =  border(ubyte mode @A, ubyte width @R1, ubyte height @R2, ubyte colors @X) clobbers(Y)       ; NOTE: mode 6 means 'custom' characters taken from r3 - r6
    extsub vtjmp + 15*3 =  save_rect(ubyte ramtype @A, bool vbank1 @Pc, uword address @R0, ubyte width @R1, ubyte height @R2) clobbers(A, X, Y)
    extsub vtjmp + 16*3 =  rest_rect(ubyte ramtype @A, bool vbank1 @Pc, uword address @R0, ubyte width @R1, ubyte height @R2) clobbers(A, X, Y)
    extsub vtjmp + 17*3 =  input_str(uword buffer @R0, ubyte buflen @Y, ubyte colors @X) clobbers (A) -> ubyte @Y     ; Y=length of input
    extsub vtjmp + 18*3 =  get_bank() clobbers (A) -> bool @Pc
    extsub vtjmp + 19*3 =  get_stride() -> ubyte @A
    extsub vtjmp + 20*3 =  get_decr() clobbers (A) -> bool @Pc

    ; -- helper function to do string length counting for you internally, and turn the convertchars flag into a boolean again
    asmsub print_str2(str txtstring @R0, ubyte colors @X, bool convertchars @Pc) clobbers(A, Y) {
        %asm {{
            lda  #0
            bcs  +
            lda  #$80
+           pha
            lda  cx16.r0
            ldy  cx16.r0+1
            jsr  prog8_lib.strlen
            pla
            jmp  print_str
        }}
    }
}
