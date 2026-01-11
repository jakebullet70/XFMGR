files_folders {
    ubyte total_dir, total_files = 0
    alias tmp_str  = main.g_tmp_str_buffer2 
    alias tmp_str0 = main.g_tmp_str_buffer3 
    const bool DIR_ENTRY = true
    const bool FILE_ENTRY = false
    const bool NOT_TAGGED = false

    sub read_folders(ubyte drv) -> bool {
        alias dir_error = main.bool_tmp
        diskio.drivenumber = drv
        dir_error = false

        arena_dirs.free_all()
        dirs_cache.num_files = 0        

                ;--- list directories first
        if diskio.lf_start_list_dirs(0) {
            while diskio.lf_next_entry() {    
                void strings.copy(diskio.list_filename, tmp_str)
                void strings.lower(tmp_str)    
                strings_ext.concat_strings("[",tmp_str,tmp_str0)
                strings_ext.concat_strings(tmp_str0,"]",tmp_str)
                ;dirs_cache.add(tmp_str,DIR_ENTRY,NOT_TAGGED,0)
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
                files_cache.add(tmp_str,FILE_ENTRY,NOT_TAGGED,diskio.list_blocks)
                total_files++       
            }
        } else {
            file_error = true
        }
        diskio.lf_end_list()
      
        return file_error
    }

}

