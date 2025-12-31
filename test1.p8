%import conv
%import textio
%import diskio
%import strings
%import syslib
%zeropage basicsafe
%option no_sysinit

; Note: this program can be compiled for multiple target systems.

main {
    
    str g_str_buffer = "?"*255
    ubyte g_base_color = 1 
      
    sub start() {
        
        ; list directories first
        if diskio.lf_start_list_dirs(0) {
            while diskio.lf_next_entry() {
                PrintLine(false)
                total_dir++       
            }
        } else {
            txt.print("error getting dirs\n")
            error = true
        }
        diskio.lf_end_list()

        ; then list files
        if diskio.lf_start_list_files(0) and not error {
            while diskio.lf_next_entry() {
                PrintLine(true)
                total_files++       
            }
        } else {
            txt.print("error getting files\n")
            error = true
        }
        diskio.lf_end_list()

        if not error {   
            txt.rvs_on()
            txt.column(0)
            pad_right("ttl files:    ttl dirs:", g_str_buffer, ' ', 39) 
            txt.print(g_str_buffer)
            txt.column(10)
            txt.print_ub(total_files)
            txt.column(23)
            txt.print_ub(total_dir)
            txt.nl()
        }
    }


    sub PrintLine(bool is_files) {
        ubyte color = ExtColor(diskio.list_filename)
        
        void strings.copy(diskio.list_filename, g_str_tmp0)
        ;g_str_tmp0 = diskio.list_filename
        void strings.lower(g_str_tmp0)
        ;txt.column(0)
        ;txt.rvs_on()    ;txt.print("\x12")
        ;txt.print(" ")
        ;txt.rvs_off()   ;txt.print("\x13")
        txt.column(1)
        txt.color(color)    
        txt.chrout('"') 
        txt.print(g_str_tmp0)
        txt.chrout('"') 

        txt.column(22)
        if is_files {
            ;g_str_tmp0 = conv.str_uw(diskio.list_blocks)
            void strings.copy(conv.str_uw(diskio.list_blocks), g_str_tmp0)
        } else {
            void strings.copy(" ", g_str_tmp0)
            ;g_str_tmp0 = " "
        }
        
        pad_left(g_str_tmp0, g_str_buffer, ' ', 6)
        txt.print(g_str_buffer) 

        if is_files {
            txt.print(" blocks\n")
        } else {
            txt.print(" <dir>\n")
        }

        txt.color(g_base_color) 
        ;txt.column(38)
        ;txt.rvs_on()    ;txt.print("\x12")
        ;txt.print(" ")
        ;txt.rvs_off()   ;txt.print("\x13")
        
        

    }
        

    sub PrintHeader() {
        txt.print("\n\n")
        pad_right("hotdir cx16 style", g_str_buffer, ' ', 39) 
        txt.rvs_on()    ;txt.print("\x12")
        txt.print(g_str_buffer)
        txt.nl()
        pad_right("curr dir ->", g_str_buffer, ' ', 39) 
        txt.rvs_on()    ;txt.print("\x12")
        txt.print(g_str_buffer)
        txt.column(11)
        txt.print(diskio.curdir())
        txt.nl()
    }


}