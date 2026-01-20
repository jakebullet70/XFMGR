files_folders {
    ubyte total_dir, total_files = 0
    alias tmp_str  = main.g_tmp_str_buffer2 
    alias tmp_str0 = main.g_tmp_str_buffer3 
    str ROOT_DIR = iso:"/"

    const ubyte FILE_MAX_LEN = 40

    sub read_dirs(ubyte drv) -> bool {
        alias dir_error = main.bool_tmp
        diskio.drivenumber = drv
        dir_error = false

        arena_dirs.free_all()

        ;dirs_cache.total_dir = 1        ;--- reset dir count
        total_dir++   
        dirs_cache.add(ROOT_DIR,0)


        ;--- list directories first
        if diskio.lf_start_list_dirs(0) {
            while diskio.lf_next_entry() {    
                void strings.copy(diskio.list_filename, tmp_str)
                void strings.lower(tmp_str)    
                strings_ext.concat_strings("[",tmp_str,tmp_str0)
                strings_ext.concat_strings(tmp_str0,"]",tmp_str)
                dirs_cache.add(tmp_str,0)
                total_dir++   
            }
        } else {
            dir_error = true
        }
        diskio.lf_end_list()
        return dir_error

    }

    
    sub read_files(ubyte drv) -> bool { 
        alias file_error = main.bool_tmp
        diskio.drivenumber = drv
        file_error = false

        arena_files.free_all()
        files_cache.num_files = 0        

        ;--- then list files
        if diskio.lf_start_list_files(0) {
            while diskio.lf_next_entry() {
                void strings.copy(diskio.list_filename, tmp_str)
                void strings.lower(tmp_str)    
                files_cache.add(tmp_str,diskio.list_blocks)
                total_files++       
            }
        } else {
            file_error = true
        }
        diskio.lf_end_list()
      
        return file_error
    }

}

