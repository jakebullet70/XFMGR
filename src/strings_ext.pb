IMPORT strings

MODULE strings_ext
    
    '--- NEEDS REFACTOR!!!!  WRITTEN BY AI
    ' Pads a string to the right with a specified character
    ' source: source string (passed by value)
    ' target: pointer to target buffer (must be pre-allocated, large enough for padded result)
    ' pad_char: character to use for padding
    ' total_len: desired total length after padding
    ' Note: if source is already >= total_len, it will be copied as-is (truncated if needed)
    SUB pad_right(source AS STRING, target AS UWORD, pad_char AS UBYTE, total_len AS UBYTE)
        DIM src_len AS UBYTE = strings.length(source)
        DIM i AS UBYTE
        
        ' Copy source string to target
        IF src_len >= total_len THEN
            ' Source is already long enough, just copy up to total_len
            FOR i = 0 TO total_len-1
                target[i] = source[i]
            NEXT
            target[total_len] = 0
        ELSE
            ' Copy source then pad
            FOR i = 0 TO src_len-1
                target[i] = source[i]
            NEXT
            ' Add padding
            FOR i = src_len TO total_len-1
                target[i] = pad_char
            NEXT
            target[total_len] = 0
        END IF
    END SUB


    '--- NEEDS REFACTOR!!!!  WRITTEN BY AI
    ' Pads a string to the left with a specified character
    ' source: source string (passed by value)
    ' target: pointer to target buffer (must be pre-allocated, large enough for padded result)
    ' pad_char: character to use for padding
    ' total_len: desired total length after padding
    ' Note: if source is already >= total_len, it will be copied as-is (truncated if needed)
    ' SUB pad_left(source AS STRING, target AS UWORD, pad_char AS UBYTE, total_len AS UBYTE)
    '     DIM src_len AS UBYTE = strings.length(source)
    '     DIM i AS UBYTE
    '     DIM pad_count AS UBYTE
        
    '     IF src_len >= total_len THEN
    '         ' Source is already long enough, just copy up to total_len
    '         FOR i = 0 TO total_len-1
    '             target[i] = source[i]
    '         NEXT
    '         target[total_len] = 0
    '     ELSE
    '         ' Add padding first
    '         pad_count = total_len - src_len
    '         FOR i = 0 TO pad_count-1
    '             target[i] = pad_char
    '         NEXT
    '         ' Then copy source
    '         FOR i = 0 TO src_len-1
    '             target[pad_count + i] = source[i]
    '         NEXT
    '         target[total_len] = 0
    '     END IF
    ' END SUB



    '--- NEEDS REFACTOR!!!!  WRITTEN BY AI
    ' Concatenates two strings together
    ' str1: first string (passed by value)
    ' str2: second string (passed by value)
    ' target: pointer to target buffer (must be pre-allocated, large enough for both strings + null)
    SUB concat_strings(str1 AS STRING, str2 AS STRING, target AS UWORD)
        DIM len1 AS UBYTE = strings.length(str1)
        
        ' Copy first string
        VOID strings.copy(str1, target)
        
        ' Copy second string after the first
        VOID strings.copy(str2, target + len1)
    END SUB


    '--- Generic string replace function
    ' Replaces all occurrences of find_str with replace_str in str_2_search
    ' str_2_search: string to search in (passed by value)
    ' find_str: string to find (passed by value)
    ' replace_str: string to replace with (passed by value)
    ' out_str: pointer to target buffer (must be pre-allocated, large enough for result)
    SUB replace(str_2_search AS STRING, find_str AS STRING, replace_str AS STRING, out_str AS UWORD)
        DIM search_len AS UBYTE = strings.length(str_2_search)
        DIM find_len AS UBYTE = strings.length(find_str)
        DIM replace_len AS UBYTE = strings.length(replace_str)
        DIM out_pos AS UBYTE = 0
        DIM i,j AS UBYTE
        DIM found AS BOOL = FALSE
        
        IF find_len == 0 THEN
            ' Empty find string, just copy source
            VOID strings.copy(str_2_search, out_str)
            RETURN
        END IF
        
        i = 0
        WHILE i < search_len
            ' Check if find_str matches at current position
            found = TRUE
            j = 0
            WHILE j < find_len AND i + j < search_len
                IF str_2_search[i + j] <> find_str[j] THEN
                    found = FALSE
                END IF
                j += 1
            WEND
            
            IF found AND j = find_len THEN
                ' Found a match, copy replace_str
                FOR j = 0 TO replace_len - 1
                    out_str[out_pos] = replace_str[j]
                    out_pos += 1
                NEXT
                i += find_len
            ELSE
                ' No match, copy character from source
                out_str[out_pos] = str_2_search[i]
                out_pos += 1
                i += 1
            END IF
        WEND
        
        out_str[out_pos] = 0  ' Null terminate
    END SUB


END MODULE





