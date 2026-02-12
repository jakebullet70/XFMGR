'==============================================================================
'---   
'---   
'---   
'==============================================================================
'---   
'==============================================================================


IMPORT line_editor
IMPORT history_popup
IMPORT stree
IMPORT key_const
IMPORT strings
IMPORT menus
IMPORT textio
IMPORT diskio
IMPORT line_editor
IMPORT linked_list_files
IMPORT files_folders
IMPORT helpers

MODULE prompts
    ALIAS i = main.i
    ALIAS j = main.j
    ALIAS input_str1 = main.g_tmp_str_buffer1
    ALIAS input_str2 = main.g_tmp_str_buffer2
    ALIAS input_str_ret_val = main.g_tmp_str_buffer3
    ALIAS CANCEL_INPUT = line_editor.CANCEL_INPUT
    DIM CR_STR AS STRING = cp437:"◄╛"
    DIM UP_STR AS STRING = cp437:"↑"
    CONST PROMPT_LINE_2 AS UBYTE = 3
    CONST PROMPT_LINE_3 AS UBYTE = 2
    CONST PROMPT_LINE_1 AS UBYTE = 4
    'DIM STR_ENTER_FILE_SPEC AS STRING = cp437:"Enter file specification"

    'txt.print_lit(cp437:"≈ IBM Pc ≈ ÇüéâäàåçêëèïîìÄ ░▒▓│┤╡╢╖╕╣║╗╝╜╛┐ ☺☻♥♦♣♠•◘○◙♂♀♪♫☼ ►◄↕‼¶§▬↨↑↓→←∟↔▲▼")



    FUNCTION file_spec() AS BOOL
        prompt_txt(cp437:"Filespec:", "",
                   cp437:"Enter file specification                             History    Ok  ESC Cancel", 0, 14, 2)
        menus.highlight_menu_keys([69, 70, 71], 2, txt.height()-2, theme.MENU_BRIGHT)
        draw_icons(53, 63, txt.height()-2)
        
        'VOID strings.copy("*.*",input_str_ret_val)                                        
       ' helpers.print_strXY(14,txt.height()-4,input_str_ret_val,theme.MENU_BRIGHT,FALSE)    '--- show filespec
        VOID strings.copy("*.*", input_str_ret_val)                              '--- working str        
        line_editor.get_txt(14, 10, PROMPT_LINE_1, [keys.ESC], 0, [keys.CR], 0, 
                                prompt_history.FILE_FILESPEC)             '--- get txt loop

        IF input_str_ret_val = CANCEL_INPUT THEN RETURN FALSE                                '--- cancel, bye!
        main.read_files(diskio.drivenumber, input_str_ret_val, files_folders.current_folder)
        RETURN TRUE

    END FUNCTION
    

    FUNCTION run_file() AS BOOL
        prompt_txt(cp437:"EXECUTE File:",cp437:"",
                   cp437:"                                                     History    Ok  ESC Cancel",0,14,2)
        menus.highlight_menu_keys([69,70,71],2,txt.height()-2,theme.MENU_BRIGHT)
        draw_icons(53,63,txt.height()-2)
        
        VOID strings.copy(files_cache.current.name,input_str_ret_val)                  '--- copy current fname to working str        
        'helpers.print_strXY(14,txt.height()-4,input_str_ret_val,theme.MENU_BRIGHT,FALSE)  '--- show fname
        line_editor.get_txt(1,14,PROMPT_LINE_2,[keys.ESC],0,[keys.CR],0,prompt_history.NOTHING)                      '--- get txt loop

        IF input_str_ret_val = CANCEL_INPUT THEN RETURN FALSE                                     '--- cancel, bye!
        RETURN FALSE
    
    END FUNCTION

    
    FUNCTION ask_exit() AS BOOL
        prompt_txt(cp437:"GO BYE BYE",cp437:"",cp437:"Quit and return to the x16?         [N]o  Yes  ESC Cancel",1,28,3)
        menus.highlight_menu_keys([38,43,48,49,50],4,txt.height()-2,theme.MENU_BRIGHT)
        VOID strings.copy("",input_str_ret_val)                  '--- working str        
        line_editor.get_txt(1,29,PROMPT_LINE_3,[keys.ESC,cp437:"n"c,cp437:"N"c,keys.CR],3,
                                [cp437:"y"c,cp437:"Y"c],1,prompt_history.NOTHING)
        IF input_str_ret_val = CANCEL_INPUT THEN RETURN FALSE
        RETURN TRUE
    END FUNCTION

    
    FUNCTION rename_file(tagged_files AS BOOL) AS BOOL
        '--- if tagged_files=true then rename multi files
        prompt_txt(cp437:"RENAME File:",
                   cp437:"         To:",
                   cp437:"Enter filename mask                                  History    Ok  ESC Cancel",
                   files_folders.FILE_MAX_LEN,14,2)
                        ' 12345678901234567890123456789012345678901234567890123456789012345678901234567890
        menus.highlight_menu_keys([69,70,71],2,txt.height()-2,theme.MENU_BRIGHT)
        draw_icons(53,63,txt.height()-2)
        
        VOID strings.copy(files_cache.current.name,input_str_ret_val)                   '--- copy current fname to working str        
        helpers.print_strXY(14,txt.height()-4,input_str_ret_val,theme.MENU_BRIGHT,FALSE)  '--- show fname
        line_editor.get_txt(1,14,3,[keys.ESC],0,[keys.CR],0,prompt_history.NOTHING)                      '--- get txt loop

        IF input_str_ret_val = CANCEL_INPUT THEN RETURN FALSE                               '--- cancel, bye!
        
        'IF NOT tagged_files THEN   '  TODO
            'diskio.rename(files_cache.current.name,input_str_ret_val)
        'ELSE
        'END IF
        RETURN TRUE '--- true tells caller to refresh screen
    END FUNCTION

    
    FUNCTION delete_file(tagged_files AS BOOL) AS BOOL
        '--- if tagged_files=true then delete multi files
        prompt_txt(cp437:"DELETE File:",cp437:"",cp437:"Delete this file?                   [N]o  Yes  ESC Cancel",1,28,3)
        menus.highlight_menu_keys([38,43,48,49,50],4,txt.height()-2,theme.MENU_BRIGHT)
        
        helpers.print_strXY(13,txt.height()-4,files_cache.current.name,theme.MENU_BRIGHT,FALSE)  '--- show fname
        VOID strings.copy("",input_str_ret_val)                                                  '---  working str = none       
        line_editor.get_txt(1,19,PROMPT_LINE_3,[keys.ESC,cp437:"n"c,cp437:"N"c,keys.CR],3,
                            [cp437:"y"c,cp437:"Y"c],1,prompt_history.NOTHING)
        IF input_str_ret_val = CANCEL_INPUT THEN RETURN FALSE 
        IF NOT tagged_files THEN
            diskio.delete(files_cache.current.name)
        ELSE

        END IF
        RETURN TRUE '--- true tells caller to refresh screen
    END FUNCTION 

    
    FUNCTION not_done_yet(dummy AS BOOL) AS BOOL
        prompt_txt(cp437:"WORKING ON IT!",cp437:"",cp437:"Under construction: ------:                    ESC Cancel",1,28,3)
        menus.highlight_menu_keys([48,49,50],2,txt.height()-2,theme.MENU_BRIGHT)
        VOID strings.copy("",input_str_ret_val)  
        line_editor.get_txt(1,29,PROMPT_LINE_3,[keys.ESC,keys.CR],1,[cp437:"Y"c],0,prompt_history.NOTHING)
        RETURN FALSE
    END FUNCTION



    '==============================================================================
    '==============================================================================
    '==============================================================================


     SUB draw_icons(col_arrow AS UBYTE, col_CR AS UBYTE, row AS UBYTE)
        IF col_arrow <> 0 THEN helpers.print_strXY(col_arrow,row,UP_STR,theme.MENU_BRIGHT,FALSE)
        IF col_CR <> 0 THEN helpers.print_strXY(col_CR,row,CR_STR,theme.MENU_BRIGHT,FALSE)
    END SUB

 
    '--- generic text input prompts text
    SUB prompt_txt(txt1 AS STRING, txt2 AS STRING, txt3 AS STRING, p_length AS UBYTE, col AS UBYTE, row AS UBYTE)
        menus.clear_menu_area()
        menus.is_prompt = TRUE                          '--- we are in a prompt!!!
        VOID strings.copy("",input_str_ret_val)         '--- clear out ret val
        txt.color2(theme.MENU_NORMAL & 15, theme.MENU_NORMAL >> 4)
        IF strings.length(txt1) <> 0 THEN helpers.print_strXY2(1,txt.height() - 4,txt1)
        IF strings.length(txt2) <> 0 THEN helpers.print_strXY2(1,txt.height() - 3,txt2)
        IF strings.length(txt3) <> 0 THEN helpers.print_strXY2(1,txt.height() - 2,txt3)
        'txt.color2(theme.MENU_EDITOR & 15, theme.MENU_EDITOR >> 4)
        'FOR j = 0 TO p_length - 1  '--- REV ON * p_length SKIPPING 
            'helpers.print_strXY2(col+j,(txt.height() - 4) + row," ") 
            'txt.setclr(col+i,(txt.height() - 4) + row,theme.MENU_EDITOR) 
        'NEXT
        'txt.color2(theme.MENU_NORMAL & 15, theme.MENU_NORMAL >> 4)
    END SUB

END MODULE
