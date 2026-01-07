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
    str g_str_tmp0 = "?"*255
    str g_str_tmp1 = "?"*255
    str[9] g_arr_str_file_ext ; = ["      ","      ","      ","      ","      ","      ","      ","      ","      ","      "]
    ubyte g_base_color = 1 
    ubyte g_ExtTTL
    
     
    sub start() {
        diskio.drivenumber = 8
        SetUpFileExtClrs()

        PrintHeader()
        ubyte total_dir, total_files=0
        bool error = false
        
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
        void strings.lower(g_str_tmp0)

        txt.column(1)
        txt.color(color)    
        txt.chrout('"') 
        txt.print(g_str_tmp0)
        txt.chrout('"') 

        txt.column(22)
        if is_files {
            void strings.copy(conv.str_uw(diskio.list_blocks), g_str_tmp0)
        } else {
            void strings.copy(" ", g_str_tmp0) ; --- zero out string
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


    sub SetUpFileExtClrs(){


        return

        void strings.copy("14!bas,14!bl,7!bat,10!prg,4!dir", g_str_buffer)
        void strings.copy("/h.dat", g_str_tmp1)
        alias file_name = g_str_tmp1
        if diskio.exists(file_name) {
            txt.print("loading file ext color config\n")
            void diskio.f_open(file_name)
            void diskio.f_readline(g_str_buffer)
        } else {
            txt.print("creating default file ext color config\n")
            void diskio.f_open_w(file_name)
            void diskio.f_write(g_str_buffer,strings.length(g_str_buffer))
        } 
        diskio.f_close() 
        return     

        g_ExtTTL = tally(g_str_buffer, ',') + 1
        ;sub splititem(str source, ubyte delimiter, ubyte index, uword target)
        for cx16.r0L in 0 to g_ExtTTL {
            void splititem(g_str_buffer,',',cx16.r0L,g_arr_str_file_ext[cx16.r0L])
        }
        

    }


    sub ExtColor(str fname) -> ubyte {
        str ext_str = "?" * 10
        GetExtension(fname,ext_str)
        void strings.lower(ext_str)
        if ext_str == "bl," {
            return 3 ; 
        } else if ext_str == "p8" {
            return 4 ; 
        } else if ext_str == "dir" {
            return 15 ; 
        } else if ext_str == "bat" {
            return 8 ; 
        } else if ext_str == "bas" {
            return 3 ; 
        } else {
            return g_base_color
        }
        
    }


    sub GetExtension(str fname,uword ext_str) {
        ubyte ln = strings.length(fname)
        if ln == 0 {
            strings.left("", 0, ext_str)
            return ;ext_str
        }

        str tmp = "?" * 128
        str ch = "?" * 1
        ubyte i = ln

        while i > 0 {
            i = i - 1
            ; get character at position i
            strings.right(fname, (ln - i), tmp)
            strings.left(tmp, 1, ch)

            if ch == "." {
                ubyte count = ln - i - 1
                if count == 0 {
                    strings.left("", 0, ext_str)
                    return ;ext_str
                } else {
                    strings.right(fname, count, ext_str)
                    return ;ext_str
                }
            }
        }

        ; no dot found
        strings.left("", 0, ext_str)
        return ;ext_str
    }


    ; Pads a string to the right with a specified character
    ; source: source string (passed by value)
    ; target: pointer to target buffer (must be pre-allocated, large enough for padded result)
    ; pad_char: character to use for padding
    ; total_len: desired total length after padding
    ; Note: if source is already >= total_len, it will be copied as-is (truncated if needed)
    sub pad_right(str source, uword target, ubyte pad_char, ubyte total_len) {
        ubyte src_len = strings.length(source)
        ubyte i
        
        ; Copy source string to target
        if src_len >= total_len {
            ; Source is already long enough, just copy up to total_len
            for i in 0 to total_len-1 {
                target[i] = source[i]
            }
            target[total_len] = 0
        } else {
            ; Copy source then pad
            for i in 0 to src_len-1 {
                target[i] = source[i]
            }
            ; Add padding
            for i in src_len to total_len-1 {
                target[i] = pad_char
            }
            target[total_len] = 0
        }
    }



    ; Pads a string to the left with a specified character
    ; source: source string (passed by value)
    ; target: pointer to target buffer (must be pre-allocated, large enough for padded result)
    ; pad_char: character to use for padding
    ; total_len: desired total length after padding
    ; Note: if source is already >= total_len, it will be copied as-is (truncated if needed)
    sub pad_left(str source, uword target, ubyte pad_char, ubyte total_len) {
        ubyte src_len = strings.length(source)
        ubyte i
        ubyte pad_count
        
        if src_len >= total_len {
            ; Source is already long enough, just copy up to total_len
            for i in 0 to total_len-1 {
                target[i] = source[i]
            }
            target[total_len] = 0
        } else {
            ; Add padding first
            pad_count = total_len - src_len
            for i in 0 to pad_count-1 {
                target[i] = pad_char
            }
            ; Then copy source
            for i in 0 to src_len-1 {
                target[pad_count + i] = source[i]
            }
            target[total_len] = 0
        }
    }


    ; Concatenates two strings together
    ; str1: first string (passed by value)
    ; str2: second string (passed by value)
    ; target: pointer to target buffer (must be pre-allocated, large enough for both strings + null)
    sub concat_strings(str str1, str str2, uword target) {
        ubyte len1 = strings.length(str1)
        
        ; Copy first string
        void strings.copy(str1, target)
        
        ; Copy second string after the first
        void strings.copy(str2, target + len1)
    }


    ; Counts the number of times a character appears in a string
    ; source: source string (passed by value)
    ; search_char: character to count
    ; Returns: number of occurrences of the character
    sub tally(str source, ubyte search_char) -> ubyte {
        ubyte count = 0
        ;ubyte len = strings.length(source)
        ubyte i
        
        for i in 0 to strings.length(source)-1 {
            if source[i] == search_char {
                count++
            }
        }
        
        return count
    }


    ; Returns a substring at a specific index from a delimited string
    ; source: source string (passed by value)
    ; delimiter: delimiter character
    ; index: which substring to extract (0-based)
    ; target: pointer to target buffer where substring will be stored
    ; Returns: true if substring found, false if index out of range
    sub splititem(str source, ubyte delimiter, ubyte index, uword target) -> ubyte {
        ubyte tlen = strings.length(source)
        ubyte current_index = 0
        ubyte start_pos = 0
        ubyte i,j
        ubyte target_pos = 0
        
        ; Clear target buffer
        target[0] = 0
        
        ; Handle empty string
        if tlen == 0
            return 0
        
        ; Find the start position of the desired substring
        for i in 0 to tlen-1 {
            if source[i] == delimiter {
                if current_index == index {
                    ; Found our substring, copy it
                    for j in start_pos to i-1 {
                        target[target_pos] = source[j]
                        target_pos++
                    }
                    target[target_pos] = 0
                    return 1
                }
                current_index++
                start_pos = i + 1
            }
        }
        
        ; Check if we're at the last substring (no delimiter at end)
        if current_index == index {
            for j in start_pos to tlen-1 {
                target[target_pos] = source[j]
                target_pos++
            }
            target[target_pos] = 0
            return 1
        }
        
        ; Index out of range
        return 0
    }
}