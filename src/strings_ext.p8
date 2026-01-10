
strings_ext {
    
    ;--- NEEDS REFACTOR!!!!  WRITTEN BY AI
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


    ;--- NEEDS REFACTOR!!!!  WRITTEN BY AI
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



    ;--- NEEDS REFACTOR!!!!  WRITTEN BY AI
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


}





