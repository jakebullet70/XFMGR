IMPORT helpers
IMPORT textio
IMPORT stree

MODULE menus
    CONST DIR AS UBYTE = 0
    CONST FILE AS UBYTE = 1
    DIM mode AS UBYTE '= TODO rename var TO view_mode

    'CONST CR_ICON AS STRING = cp437:"◄╛"

    DIM CTRL_PRESSED, ALT_PRESSED AS BOOL = FALSE
    DIM is_ctrl_dir_menu, is_alt_dir_menu, is_ctrl_file_menu, is_alt_file_menu AS BOOL = FALSE
    DIM is_dir_menu, is_file_menu, is_prompt AS BOOL = FALSE

    
    SUB highlight_menu_keys(cols[] AS UBYTE, alen AS UBYTE, row AS UBYTE, ccolor AS UBYTE)
        ALIAS i = main.i
        FOR i = 0 TO alen
            txt.setclr(cols[i], row, ccolor) 
        NEXT
    END SUB

    SUB clear_menu_area()
        ALIAS j = main.j
        txt.color2(theme.MENU_NORMAL & 15, theme.MENU_NORMAL >> 4)
        FOR j = 4 DOWNTO 2
            helpers.print_strXY2(1, txt.height() - j, " " * 78)
        NEXT
    END SUB

    SUB show_menu_header(mtype AS STRING, DIRorFILE AS STRING)
        clear_menu_area()
        helpers.print_strXY2(1, txt.height() - 4, mtype)
        helpers.print_strXY2(1, txt.height() - 3, cp437:"COMMANDS")
        helpers.print_strXY2(1, txt.height() - 2, DIRorFILE)
        helpers.print_strXY(6, txt.height() - 2, cp437:"◄╛", theme.MENU_BRIGHT, FALSE)
        txt.color2(theme.MENU_NORMAL & 15, theme.MENU_NORMAL >> 4)
    END SUB

    SUB clear_modifier_flags()
        is_ctrl_dir_menu = is_alt_dir_menu = is_ctrl_file_menu = is_alt_file_menu = FALSE
    END SUB

    SUB draw()
        'debug.say2("modifer_key:",modifer_key)
        'DIM is_ctrl_dir_menu, is_alt_dir_menu, is_ctrl_file_menu, is_alt_file_menu AS BOOL = FALSE
        is_prompt = FALSE
        SELECT CASE mode
            CASE DIR
                
                IF NOT ALT_PRESSED AND NOT CTRL_PRESSED THEN
                    clear_modifier_flags()
                    is_dir_menu = TRUE
                    is_file_menu = FALSE
                    show_menu_header(cp437:"DIR", cp437:"File")
                    '--- 1st line
                    helpers.print_strXY2(12, txt.height() - 4, cp437:"Avail  Delete  Filespec  Log  Make")
                    highlight_menu_keys([12, 19, 27, 37, 42], 4, txt.height() - 4, theme.MENU_BRIGHT)
                    '--- line2 
                    helpers.print_strXY2(12, txt.height() - 3, cp437:"Rename  Tag  Untag  Quit")
                    highlight_menu_keys([12, 20, 25, 32], 3, txt.height() - 3, theme.MENU_BRIGHT)

                ELSEIF ALT_PRESSED THEN
                    is_alt_dir_menu = TRUE
                    is_dir_menu = is_file_menu = FALSE
                    show_menu_header(cp437:"ALT DIR", cp437:"File")
                    '--- 1st line
                    helpers.print_strXY2(12, txt.height() - 4, cp437:"Edit  Graft  Log  Prune")
                    highlight_menu_keys([12, 18, 25, 30], 3, txt.height() - 4, theme.MENU_BRIGHT)
                    '--- line2 
                    helpers.print_strXY2(12, txt.height() - 3, cp437:"Tag  Untag  Quit")
                    highlight_menu_keys([12, 17, 24], 2, txt.height() - 3, theme.MENU_BRIGHT)

                ELSEIF CTRL_PRESSED THEN
                    is_ctrl_dir_menu = TRUE
                    is_dir_menu = is_file_menu = FALSE
                    show_menu_header(cp437:"CTRL DIR", cp437:"File")
                    '--- 1st line
                    helpers.print_strXY2(12, txt.height() - 4, cp437:"Log  Tag  Untag")
                    highlight_menu_keys([12, 17, 22], 2, txt.height() - 4, theme.MENU_BRIGHT)
                END IF

            CASE FILE
                IF NOT ALT_PRESSED AND NOT CTRL_PRESSED THEN
                    clear_modifier_flags()
                    is_dir_menu = FALSE
                    is_file_menu = TRUE
                    show_menu_header(cp437:"FILE", cp437:"Dir")
                    '--- 1st line
                    helpers.print_strXY2(12, txt.height() - 4, cp437:"Copy  Delete  Edit  Filespec  Log  Move")
                    highlight_menu_keys([12, 18, 26, 32, 42, 47], 5, txt.height() - 4, theme.MENU_BRIGHT)
                    '--- line2 
                    helpers.print_strXY2(12, txt.height() - 3, cp437:"New date  Print  Rename  Tag  Untag  View  eXecute  Quit")
                    highlight_menu_keys([12, 22, 29, 37, 42, 49, 56, 64], 7, txt.height() - 3, theme.MENU_BRIGHT)

                ELSEIF ALT_PRESSED THEN
                    is_alt_file_menu = TRUE
                    is_dir_menu = is_file_menu = FALSE
                    show_menu_header(cp437:"ALT FILE", cp437:"Dir")
                    '--- 1st line
                    helpers.print_strXY2(12, txt.height() - 4, cp437:"Copy  Log  Move")
                    highlight_menu_keys([12, 18, 23], 2, txt.height() - 4, theme.MENU_BRIGHT)
                    '--- line2 
                    helpers.print_strXY2(12, txt.height() - 3, cp437:"Tag  Untag  Quit")
                    highlight_menu_keys([12, 17, 24], 2, txt.height() - 3, theme.MENU_BRIGHT)

                ELSEIF CTRL_PRESSED THEN
                    is_ctrl_file_menu = TRUE
                    is_dir_menu = is_file_menu = FALSE
                    show_menu_header(cp437:"CTRL FILE", cp437:"Dir")
                    '--- 1st line
                    helpers.print_strXY2(12, txt.height() - 4, cp437:"Copy  Delete  Log  Move  New date  Print")
                    highlight_menu_keys([12, 18, 26, 31, 37, 47], 5, txt.height() - 4, theme.MENU_BRIGHT)
                    '--- line2 
                    helpers.print_strXY2(12, txt.height() - 3, cp437:"Rename  Search  Tag  Untag  View")
                    highlight_menu_keys([12, 20, 28, 33, 40], 4, txt.height() - 3, theme.MENU_BRIGHT)

                END IF
        END SELECT
    END SUB
END MODULE