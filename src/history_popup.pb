'==============================================================================
'---   
'---   prompt_history.pb,  generic popup for line editor history
'---   
'==============================================================================
'---   
'==============================================================================


MODULE prompt_history

   
    CONST NOTHING AS UBYTE = 0
    CONST FILE_FILESPEC AS UBYTE = 1
    
    'DIM hist_fname AS STRING = "?" * 7


    SUB popup(what AS UBYTE)

        ALIAS i = main.i
        ALIAS j = main.j

        screen.store()

        '--- draw cool box
        helpers.draw_box(10,13,36,43, theme.BOX2)
        helpers.clear_section(10+1,13+1,36-2,43-2, theme.BOX2) 


        kcode:
        DIM keycode AS UBYTE = cbm.GETIN2()             
        IF keycode = 0 THEN GOTO kcode

        SELECT CASE what
            CASE FILE_FILESPEC
                read_file_print_2_scrn("f-f.hst")
        END SELECT

        screen.restore()
    END SUB


    SUB read_file_print_2_scrn(fname AS STRING)

    END SUB

    SUB append_2_hist_file(fname AS STRING)

    END SUB

END MODULE
