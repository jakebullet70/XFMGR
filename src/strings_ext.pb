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
    SUB pad_left(source AS STRING, target AS UWORD, pad_char AS UBYTE, total_len AS UBYTE)
        DIM src_len AS UBYTE = strings.length(source)
        DIM i AS UBYTE
        DIM pad_count AS UBYTE
        
        IF src_len >= total_len THEN
            ' Source is already long enough, just copy up to total_len
            FOR i = 0 TO total_len-1
                target[i] = source[i]
            NEXT
            target[total_len] = 0
        ELSE
            ' Add padding first
            pad_count = total_len - src_len
            FOR i = 0 TO pad_count-1
                target[i] = pad_char
            NEXT
            ' Then copy source
            FOR i = 0 TO src_len-1
                target[pad_count + i] = source[i]
            NEXT
            target[total_len] = 0
        END IF
    END SUB



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


END MODULE





