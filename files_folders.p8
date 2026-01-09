files_folders {

    bool disk_error = false
    ubyte total_dir, total_files = 0
    alias tmp_str  = main.g_tmp_str_buffer2 
    alias tmp_str0 = main.g_tmp_str_buffer3 
    const bool DIR_ENTRY = true
    const bool FILE_ENTRY = false
    const bool NOT_TAGGED = false
    
    sub read(ubyte drv) -> bool { 
        diskio.drivenumber = drv
        ;reset_mem()
        arena.free_all()
        dir_cache.count = 0        

        ;--- list directories first
        if diskio.lf_start_list_dirs(0) {
            while diskio.lf_next_entry() {    
                void strings.copy(diskio.list_filename, tmp_str)
                void strings.lower(tmp_str)    
                strings_ext.concat_strings("[",tmp_str,tmp_str0)
                strings_ext.concat_strings(tmp_str0,"]",tmp_str)
                dir_cache.add(tmp_str,DIR_ENTRY,NOT_TAGGED,0)
                total_dir++   
            }
        } else {
            disk_error = true
        }
        diskio.lf_end_list()

        ;--- then list files
        if diskio.lf_start_list_files(0) and not disk_error {
            while diskio.lf_next_entry() {
                void strings.copy(diskio.list_filename, tmp_str)
                void strings.lower(tmp_str)    
                dir_cache.add(tmp_str,FILE_ENTRY,NOT_TAGGED,diskio.list_blocks)
                total_files++       
            }
        } else {
            disk_error = true
        }
        diskio.lf_end_list()

        return disk_error
    }

}

