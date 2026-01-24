files_folders {

    ubyte counted_dir, counted_files = 0
    alias tmp_str  = main.g_tmp_str_buffer2 
    alias tmp_str0 = main.g_tmp_str_buffer3 
    str ROOT_DIR = "   "
    str current_folder = "?" * main.DEF_PATH_LENGTH

    str filter_dir   = "?"*25
    str filter_files = "?"*35
    
    const ubyte FILE_MAX_LEN = 40
    const ubyte FILE_MAX_LEN_CLEAR = 42

    sub load_dirs(ubyte drv,str filter,ubyte dir_level) -> bool {
        alias dir_error = main.bool_tmp
        diskio.drivenumber = drv
        dir_error = false

        arena_dirs.free_all()
        counted_dir = 0
        void strings.ncopy(filter,filter_dir,25)

        if dir_level == 0 {
            counted_dir++   ;--- dir level 0 - add ROOT
            strings_ext.concat_strings(conv.str_ub(drv),":/",ROOT_DIR)
            dirs_cache.add(ROOT_DIR,0)
        }

        ;--- list directories first
        if diskio.lf_start_list_dirs(filter_dir) {
            while diskio.lf_next_entry_nocase() {    
                void strings.copy(diskio.list_filename, tmp_str)
                ;void strings.lower_iso(tmp_str)    
                ;strings_ext.concat_strings("[",tmp_str,tmp_str0)
                ;strings_ext.concat_strings(tmp_str0,"]",tmp_str)
                dirs_cache.add(tmp_str,dir_level)
                counted_dir++   
            }
        } else {
            dir_error = true
        }
        diskio.lf_end_list()
        return dir_error

    }

    
    sub clear_files() {
        arena_files.free_all()
        files_cache.num_files = 0  
        counted_files = 0
        void strings.copy(iso:"",current_folder) ; clear old
    }


    sub load_files(ubyte drv,str filter) -> bool { 
        alias file_error = main.bool_tmp
        diskio.drivenumber = drv
        file_error = false

        clear_files()
        void strings.ncopy(filter,filter_files,35)
        void strings.copy(diskio.curdir(),current_folder)    
        ;debug.say(current_folder)

        ;--- then list files
        if diskio.lf_start_list_files(filter_files) {
            while diskio.lf_next_entry_nocase() {
                void strings.copy(diskio.list_filename, tmp_str)
                ;void strings.lower_iso(tmp_str)    
                files_cache.add(tmp_str,diskio.list_blocks)
                counted_files++       
            }
        } else {
            file_error = true
        }
        diskio.lf_end_list()
      
        return file_error
    }

}

