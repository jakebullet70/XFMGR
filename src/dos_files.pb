'==============================================================================
'---   
'---   dos_files.pb,  DOS & misc file subs - functions
'---   
'==============================================================================
'---   
'==============================================================================

IMPORT strings

MODULE DOS

    CONST DOS_SLASH AS UBYTE = 47
    DIM flen,dlen,i,j AS UBYTE 
    DIM l_tmp AS LONG
    DIM tmp_str3 AS STRING = "?" * 100
   
    ' SUB rename(str oldfileptr, str newfileptr) 
    '     '; -- copy a file ON the drive
    '     list_filename[0] = 'c'                 
    '     list_filename[1] = ':'
    '     UBYTE flen_new = strings.copy(newfileptr, &list_filename+2)
    '     list_filename[flen_new+2] = "="c
    '     UBYTE flen_old = strings.copy(oldfileptr, &list_filename+3+flen_new)
    '     cbm.SETNAM(3+flen_new+flen_old, list_filename)
    '     cbm.SETLFS(1, drivenumber, 15)
    '     VOID cbm.OPEN()
    '     cbm.CLRCHN()
    '     cbm.CLOSE(1)     TODO - Do we need this?  needs testing
    ' END SUB            

    '--- Split a full path into directory and filename
    ' path: input path string
    ' dir_out: output buffer for directory (may include trailing separator)
    ' file_out: output buffer for filename
    SUB split_path_file(path AS STRING, dir_out AS STRING, file_out AS STRING)
        ALIAS plen = dlen
        ALIAS sep_pos  = l_tmp
        plen = strings.length(path)

        'DIM sep_pos AS LONG = -1
        sep_pos = -1
        IF plen = 0 THEN
            VOID strings.copy("", dir_out)
            VOID strings.copy("", file_out)
            RETURN
        END IF

        FOR i = plen - 1 TO 0 STEP -1
            ALIAS ch = j
            ch = path[i]
            IF ch = DOS_SLASH THEN ' OR ch = 92 OR ch = 58 THEN   ' '/', '\\', ':'
                sep_pos = i
                BREAK
            END IF
        NEXT

        IF sep_pos = -1 THEN
            '--- no separator found, whole path is filename
            VOID strings.copy(path, file_out)
            VOID strings.copy("", dir_out)
        ELSE
            '--- dir includes separator at sep_pos
            VOID strings.slice(path, 0, sep_pos + 1 AS UBYTE, dir_out)
            VOID strings.slice(path, sep_pos + 1 AS UBYTE, 255, file_out)
        END IF
    END SUB



    '--- Join a directory and filename into a full path
    ' dir: directory portion (may be empty or end with separator)
    ' file: filename portion
    ' out: output buffer for full path
    FUNCTION join_path_file(dir AS STRING, file AS STRING) AS STRING
        
        ALIAS out = tmp_str3
        'flen = strings.length(file)
        dlen = strings.length(dir)
        'DIM lastch AS UBYTE
        ALIAS lastch = i
        
        IF dlen = 0 THEN
            VOID strings.copy(file, out)
        ELSE
            lastch = dir[dlen - 1]
            IF lastch = DOS_SLASH THEN 'OR lastch = 92 OR lastch = 58 THEN
                '--- dir already ends with separator
                VOID strings.copy(dir, out)
                VOID strings.copy(file, &out + dlen)
            ELSE
                '--- need to add separator '/'
                VOID strings.copy(dir, out)
                out[dlen] = DOS_SLASH ' '/'
                out[dlen + 1] = 0
                VOID strings.copy(file, &out + dlen + 1)
            END IF
        END IF       
        RETURN out

    END FUNCTION

END MODULE