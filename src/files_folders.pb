IMPORT diskio
IMPORT strings
IMPORT strings_ext
IMPORT linked_list_dirs
IMPORT linked_list_files
IMPORT stree
IMPORT conv

MODULE files_folders

    DIM counted_dir, counted_files AS UBYTE = 0
    ALIAS tmp_str  = main.g_tmp_str_buffer2 
    ALIAS tmp_str0 = main.g_tmp_str_buffer3 
    DIM ROOT_DIR AS STRING = "   "
    DIM current_folder AS STRING = "?" * main.DEF_PATH_LENGTH

    DIM filter_dir AS STRING = "?"*25
    DIM filter_files AS STRING = "?"*35
    
    CONST FILE_MAX_LEN AS UBYTE = 40
    CONST FILE_MAX_LEN_CLEAR AS UBYTE = 42

    FUNCTION log_drive(drv AS UBYTE) AS BOOL
        ALIAS dir_error = main.bool_tmp
        
        diskio.drivenumber = drv
        dir_error = FALSE

        arena_dirs.free_all()
        counted_dir = 1

        strings_ext.concat_strings(conv.str_ub(drv), ":/", ROOT_DIR)
        dirs_cache.add(ROOT_DIR, 0)

        '--- list directories first
        IF diskio.lf_start_list_dirs(0) THEN
            WHILE diskio.lf_next_entry_nocase()
                VOID strings.copy(diskio.list_filename, tmp_str)
                dirs_cache.add(tmp_str, 1)
                counted_dir++   
            WEND
        ELSE
            dir_error = TRUE
        END IF

        diskio.lf_end_list()
        RETURN dir_error

    END FUNCTION

    FUNCTION load_dirs(drv AS UBYTE, filter AS STRING, dir_level AS UBYTE) AS BOOL
        ALIAS dir_error = main.bool_tmp
        diskio.drivenumber = drv
        dir_error = FALSE

        arena_dirs.free_all()
        counted_dir = 0
        VOID strings.ncopy(filter,filter_dir,25)

        IF dir_level = 0 THEN
            counted_dir++   '--- dir level 0 - add ROOT
            strings_ext.concat_strings(conv.str_ub(drv),":/",ROOT_DIR)
            dirs_cache.add(ROOT_DIR,0)
        END IF

        '--- list directories first
        IF diskio.lf_start_list_dirs(filter_dir) THEN
            WHILE diskio.lf_next_entry_nocase()
                VOID strings.copy(diskio.list_filename, tmp_str)
                dirs_cache.add(tmp_str,dir_level)
                counted_dir++   
            WEND
        ELSE
            dir_error = TRUE
        END IF
        diskio.lf_end_list()
        RETURN dir_error

    END FUNCTION

    
    SUB clear_files()
        arena_files.free_all()
        files_cache.selected_line_on_page = files_cache.ttl_num_files = files_cache.num_tagged = counted_files = 0
        VOID strings.copy(iso:"",current_folder) ' clear old
    END SUB


    FUNCTION load_files(drv AS UBYTE, filter AS STRING) AS BOOL
        ALIAS file_error = main.bool_tmp
        diskio.drivenumber = drv
        file_error = FALSE

        clear_files()
        VOID strings.ncopy(filter,filter_files,35)
        VOID strings.copy(diskio.curdir(),current_folder)    
        'debug.say(current_folder)

        '--- then list files
        IF diskio.lf_start_list_files(filter_files) THEN
            WHILE diskio.lf_next_entry_nocase()
                VOID strings.copy(diskio.list_filename, tmp_str)   
                files_cache.add(tmp_str,diskio.list_blocks)
                counted_files++       
            WEND
        ELSE
            file_error = TRUE
        END IF
        diskio.lf_end_list()
      
        RETURN file_error
    END FUNCTION

END MODULE

