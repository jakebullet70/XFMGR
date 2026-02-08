
IMPORT diskio
IMPORT textio
IMPORT strings
IMPORT syslib  
'--- code modules
'IMPORT helpers
'IMPORT key_const
IMPORT debug
'---
'ENCODING "cp437"
OPTION no_sysinit
ZEROPAGE basicsafe


MODULE theme
    '--- default colors
    CONST TXT_NORMAL AS UBYTE = $b1  ' 
    CONST TXT_BRIGHT AS UBYTE = $b7  ' 

    CONST X16EDITOR_NORMAL AS UBYTE = $b3
    CONST X16EDITOR_HEADER AS UBYTE = 0 '$3b
    CONST X16EDITOR_STATUS AS UBYTE = $7b

    CONST MENU_NORMAL AS UBYTE = $b3  '
    CONST MENU_BRIGHT AS UBYTE = $b7  '
    'CONST MENU_EDITOR AS UBYTE = $3b  '  reverse of MENU_BRIGHT

    CONST ROW_HILIGHT AS UBYTE = $e1

    CONST BOXES AS UBYTE = $be 
    CONST BOX2 AS UBYTE = $eb
    CONST BOX2_ROW_HILIGHT AS UBYTE = $e3
END MODULE

MODULE main    
    DIM g_tmp_str_buffer1 AS STRING = "?" * 160       '--- tmp vars to be (re)used wherever
    DIM g_tmp_str_buffer2 AS STRING = "?" * 160
    DIM g_tmp_str_buffer3 AS STRING = "?" * 160
    DIM i, j, x, y AS UBYTE @zp = 0
    
    CONST ROW_START AS UBYTE = 50
    CONST COL_START AS UBYTE = 12
    CONST ROW_WIDTH AS UBYTE = 45

    DIM num_entries, top_index, selected_index AS UBYTE = 0

    SUB start()
        ALIAS fname = g_tmp_str_buffer1
         txt.cp437()      

        VOID strings.copy(iso:"/src/hist/f-f.hst", fname)

        IF strings.length(fname) = 0 THEN RETURN
        
        prep_read_file(fname) '--- sets num_entries
        IF num_entries = 0 THEN RETURN 

        REPEAT
            
            DIM keycode AS UBYTE = cbm.GETIN2()
            IF keycode = 0 THEN CONTINUE
            
            IF keys.UP_ARROW_PRESSED IN main.last_keys THEN
                select_up()
                CONTINUE
            END IF
            IF keys.DN_ARROW_PRESSED IN main.last_keys THEN
                select_down()
                CONTINUE
            END IF

        '     SELECT CASE main.keycode_ext
        '         CASE keys.ESC
        '             BREAK '--- cancel, don't change input buffer
        '         CASE keys.CR
        '             '--- accept selection: copy into line editor buffer
        '             DIM sel AS STRING = "?"*55 
        ' '            history_menu.get_selected()
        '  '           VOID strings.copy(history_menu.tmp_str, main.g_tmp_str_buffer3)
        '             BREAK
        '         CASE ELSE
        '             '--- ignore other keys
        '     END SELECT
         END REPEAT

        
        'screen.restore()

    END SUB


END MODULE










MODULE keys

    '--- keycode_ext Keys ALT-CTRL -------------
    CONST EXT_ALT_DN AS UBYTE = 60
    CONST EXT_ALT_UP AS UBYTE = 188
    CONST EXT_CTRL_DN AS UBYTE = 58
    CONST EXT_CTRL_UP AS UBYTE = 186
    '--- keycode keys --------------------------
    CONST UP_ARROW_PRESSED AS UBYTE = 145
    CONST DN_ARROW_PRESSED AS UBYTE = 17
    CONST PAGE_DN_PRESSED AS UBYTE = 51
    CONST PAGE_UP_PRESSED AS UBYTE = 57
    '--- editing -------------------------------
    CONST LEFT_ARROW AS UBYTE = $4f
    CONST RIGHT_ARROW AS UBYTE = $59
    CONST UP_ARROW AS UBYTE = $53
    CONST DELETE AS UBYTE = $4c
    CONST INSERT AS UBYTE = $4b
    CONST BACKSPACE AS UBYTE = $0f
    CONST HOME AS UBYTE = $50
    CONST END_KEY AS UBYTE = $51

    '--- Up/Down hex codes ----------------------
    CONST Q_PRESSED AS UBYTE = $11
    CONST C_PRESSED AS UBYTE = $30
    CONST R_PRESSED AS UBYTE = $14
    CONST D_PRESSED AS UBYTE = $21
    CONST X_PRESSED AS UBYTE = $2f

    CONST E_PRESSED AS UBYTE = $13
    CONST F_PRESSED AS UBYTE = $22
    CONST L_PRESSED AS UBYTE = $27
    CONST M_PRESSED AS UBYTE = $34

    CONST V_PRESSED AS UBYTE = $31
    CONST U_PRESSED AS UBYTE = $17
    CONST T_PRESSED AS UBYTE = $15
    CONST P_PRESSED AS UBYTE = $1A
    CONST N_PRESSED AS UBYTE = $33
    CONST A_PRESSED AS UBYTE = $1f
    CONST G_PRESSED AS UBYTE = $23
    CONST S_PRESSED AS UBYTE = $20

    CONST ESC AS UBYTE = 27
    CONST CR AS UBYTE = 13
    CONST TAB AS UBYTE = 9

END MODULE



'==============================================================================
'---   
'---   helpers.pb  --> misc code
'---   
'==============================================================================
'---   
'==============================================================================


'--- misc functions
MODULE helpers
    DIM chr_topleft, chr_topright, chr_botleft, chr_botright AS UBYTE
    DIM chr_tleft, chr_tright, chr_tup, chr_tdown, chr_horiz, chr_vert AS UBYTE
    DIM i, j, x AS UBYTE    
    

    SUB print_strXY(col AS UBYTE, row AS UBYTE, txtstring AS STRING, colors AS UBYTE, convertchars AS BOOL)
        txt.plot(col, row)
        txt.color2(colors BITAND 15, colors SHR 4)
        txt.print_lit(txtstring)
        '--- convertchars NOT BEING USED    
    END SUB

    SUB print_strXY2(col AS UBYTE, row AS UBYTE, txtstring AS STRING)
        txt.plot(col, row)
        txt.print_lit(txtstring)
    END SUB

    SUB plot_charXY(col AS UBYTE, row AS UBYTE, char AS UBYTE, colors AS UBYTE)
        txt.setcc2(col, row, char, colors)
    END SUB

    SUB clear_section(col AS UBYTE, row AS UBYTE, width AS UBYTE, height AS UBYTE, colors AS UBYTE)
        txt.color2(colors BITAND 15, colors SHR 4)
        REPEAT height
            txt.plot(col, row)
            REPEAT width 
                txt.chrout_lit(32)
            END REPEAT
            row++
        END REPEAT
    END SUB

    SUB clr_section(col AS UBYTE, row AS UBYTE, width AS UBYTE, height AS UBYTE, colors AS UBYTE)
        REPEAT height
            i=0
            REPEAT width 
                txt.setclr(col+i, row, colors)
                i++
            END REPEAT
            row++
        END REPEAT
    END SUB


    SUB draw_box(col AS UBYTE, row AS UBYTE, width AS UBYTE, height AS UBYTE, colors AS UBYTE)
        ALIAS rows = j  
        rows = txt.height()
        ALIAS col_right = x
        col_right = col+width-1 
        POKEW 903, 65 '--- change scrn height so no scroll  

        txt.color2(colors BITAND 15, colors SHR 4)

        draw_horiz_line(col, row, width, colors)
        txt.plot(col, row)
        txt.chrout_lit(chr_topleft)
        txt.plot(col_right, row)
        txt.chrout_lit(chr_topright)

        i = row + 1
        REPEAT height -1
            txt.plot(col, i)
            txt.chrout_lit(chr_vert)
            txt.plot(col_right, i)
            txt.chrout_lit(chr_vert)
            i++
        END REPEAT
        
        draw_horiz_line(col, row+height-1, width, colors)
        txt.plot(col, row+height-1)
        txt.chrout_lit(chr_botleft)
        txt.plot(col_right, row+height-1)
        txt.chrout_lit(chr_botright)
        POKEW 903, rows   '--- restore screen height    
    END SUB

    SUB set_characters(iso_chars AS BOOL)
        IF iso_chars THEN
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
        ELSE
            ' PETSCII box symbols
            chr_topleft = "┌"c
            chr_topright = "┐"c
            chr_botleft = "└"c
            chr_botright = "┘"c
            chr_horiz = "─"c
            chr_vert = "│"c
            chr_tleft = "├"c
            chr_tright = "┤"c
        END IF
    END SUB

    SUB draw_main_scrn()
        txt.clear_screen()
        draw_box(0, 0, txt.width(), txt.height(), theme.BOXES)
        draw_horiz_line(0, txt.height() - 5, txt.width(), theme.BOXES)
        draw_horiz_line(0, 2, txt.width(), theme.BOXES)
        draw_horiz_line(0, 4, txt.width(), theme.BOXES)
        draw_vert_line(30, 4, txt.height()-5, theme.BOXES)
        plot_charXY(30, 4, chr_tdown, theme.BOXES)
        plot_charXY(30, txt.height()-5, chr_tup, theme.BOXES)
        
        print_strXY(1 , 1, iso:"XFMGR V0.1.0", theme.TXT_NORMAL, FALSE)
        'print_strXY(63,1,iso:"Dec 29 - 02:30PM",theme.TXT_NORMAL,FALSE)
        print_strXY(1 , 3, iso:"Path:", theme.TXT_NORMAL, FALSE)
        'print_strXY(32,3,iso:"Files",theme.TXT_NORMAL,FALSE)
    END SUB

    SUB draw_horiz_line(col AS UBYTE, row AS UBYTE, width AS UBYTE, colors AS UBYTE)
        txt.plot(col, row)
        txt.color2(colors BITAND 15, colors SHR 4)
        REPEAT width
            txt.chrout_lit(chr_horiz)
        END REPEAT
        plot_charXY(col,row,chr_tleft,colors)
        plot_charXY(col+width-1,row,chr_tright,colors)
    END SUB

    SUB draw_vert_line(col AS UBYTE, row AS UBYTE, height AS UBYTE,colors AS UBYTE)
        txt.color2(colors BITAND 15, colors SHR 4)
        REPEAT height-2
            txt.plot(col,row)
            txt.chrout_lit(chr_vert)
            row++
        END REPEAT
    END SUB


    ' '=======================================================================================

    ' SUB edit_file(filename AS UWORD)
    '     ' activate rom based x16edit, see https://github.com/stefan-b-jakobsson/x16-edit/tree/master/docs
    '     main.custom_keyboard_handler_on_off(FALSE) '--- is this needed  TODO

    '     '--- TODO,  x16editor can change folders so we need to check when we return
    '     '---        that we are still in the same folder when we started

    '     DIM x16edit_bank AS UBYTE = cx16.search_x16edit()
    '     IF x16edit_bank < 255 THEN
    '         sys.enable_caseswitch()     ' workaround for character set issue in X16Edit 0.7.1  TODO, needed now?
    '         DIM filename_length AS UBYTE = 0
    '         IF filename <> 0 THEN
    '             filename_length = strings.length(filename)
    '         END IF
    '         DIM old_bank AS UBYTE = cx16.getrombank()
    '         cx16.rombank(x16edit_bank)
    '         cx16.x16edit_loadfile_options(1, 255, filename,
    '             mkword(%00000011, filename_length),         ' auto-indent and word-wrap enable
    '             mkword(80, 4),          ' wrap and tabstop
    '             mkword(theme.X16EDITOR_NORMAL, diskio.drivenumber),
    '             mkword(theme.X16EDITOR_HEADER,theme.X16EDITOR_STATUS))
    '             'mkword(background_color<<4 | text_color, diskio.drivenumber),
    '             'mkword(0,0))
    '         cx16.rombank(old_bank)
    '         sys.disable_caseswitch()
    '     ELSE
    '         'err.print("error: no x16edit found in rom")
    '         'sys.wait(180)
    '     END IF
    '     main.custom_keyboard_handler_on_off(TRUE)   '--- is this needed  TODO
    ' END SUB



    SUB run_file()
        ' CLS : LOCATE 10,1 : PRINT : PRINT "STARTING BASLOAD..."
        ' PRINT "BASLOAD";CHR$(34) + FILE_TO_COMP$ + CHR$(34) + "{UP}{UP}";:
        ' KBBUFFER_OUT = $FEC3 : A.REG = 780
        ' POKE A.REG,13       : SYS KBBUFFER_OUT
        ' POKE A.REG,ASC("R") : SYS KBBUFFER_OUT
        ' POKE A.REG,ASC("U") : SYS KBBUFFER_OUT
        ' POKE A.REG,ASC("N") : SYS KBBUFFER_OUT
        ' POKE A.REG,ASC(":") : SYS KBBUFFER_OUT
        ' POKE A.REG,13       : SYS KBBUFFER_OUT

        ' txt.clear_screen()
        ' txt.plot(0,10)
        ' txt.ptint("load")
        ' txt.print()
        ' txt.print(flags.run_at_exit_str)
    END SUB


END MODULE
