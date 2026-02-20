OPTION no_sysinit
ZEROPAGE basicsafe

IMPORT textio
IMPORT conv

MODULE main

    SUB start()
        ' Start memory address
        DIM memPos AS PTR UBYTE = $A000

        'DIM abc AS DirectoryManager.DirEntry
        DIM temp AS PTR UBYTE = TYPEDADDR(memPos)
        ' Print info about the memory address to check that the pointer works correctly
        PrintMemAndValue(memPos)

        memPos++
        PrintMemAndValue(memPos)
        memPos--
        txt.print("changing value of ") : txt.print_uwhex(memPos, TRUE) : txt.print("\n")
        poke(memPos, 123)
        PrintMemAndValue(memPos)

        ' Increment pointer by 1 and check value again
        memPos++
        PrintMemAndValue(memPos)
        memPos++
        PrintMemAndValue(memPos)

        'Restart pointer and try using + operator and array access operator
        memPos = $A000
        txt.print("alterna ") : txt.print_uwhex(memPos + 0, TRUE) : txt.print(" is ") : txt.print_ub(memPos[0]) : txt.print("\n")
        txt.print("alterna ") : txt.print_uwhex(memPos + 1, TRUE) : txt.print(" is ") : txt.print_ub(memPos[1]) : txt.print("\n")
        txt.print("alterna ") : txt.print_uwhex(memPos + 2, TRUE) : txt.print(" is ") : txt.print_ub(memPos[2]) : txt.print("\n")

        DirectoryManager.Initialize()

        DIM entry1 AS PTR DirectoryManager.DirEntry

        entry1 = DirectoryManager.CreateDirEntry()

        txt.print("address ") : txt.print_uwhex(entry1, TRUE)

    END SUB

    SUB PrintMemAndValue(memoryPosition AS PTR UBYTE)
        txt.print("address ") : txt.print_uwhex(memoryPosition, TRUE) : txt.print(" is ") : txt.print_ub(memoryPosition^^) : txt.print("\n")
    END SUB

END MODULE

MODULE DirectoryManager
    ''' The size of the DirEntry type in bytes.
    CONST TYPE_SIZE_DIRENTRY AS UBYTE = 35

    ''' The memory location of the bitmap representing DirEntry.
    CONST ADDR_DIRENTRIES_BITMAP AS UWORD = $A000

    ''' The memory location of the DirEntry instances.
    CONST ADDR_DIRENTRIES_DATA AS UWORD = $A000 + TYPE_SIZE_DIRENTRY ' Root of bank + 1 entry that holds bitmap
    
    ''' The bank number where the bitmap and DirEntry instances are stored.
    CONST BANK_DIR_ENTRIES AS UBYTE = 40 '$28

    CONST BANK_DIR_STRINGS AS UBYTE = 41 '$29

    ' XTREE 2.0 used approximately 150K of memory. Files were restricted to 8.3 and directories were
    ' restricted to 8.3 with a max of 64 entries per directory.

    ' We have 8kb of memory in a single bank to store directory strings. If we restrict the size of
    ' strings to 48 bytes, we can store 170 entries in a single bank. However, we want to store a bitmap
    ' showing what is reserved, which takes up one entry (really just 21 bytes)
    
    ' We don't need any managers except for methods to clear out a string, copy to and from the bank,
    ' perhaps get the length of a STRING because it's either terminated by a null 0 or it's 48 bytes
    ' long. However length is something we could return automatically when we copy from the bank.

    ' Other considerations:
    
    ' What if we did something similar to FAT? FAT just had a file named the directory that was a flag to indicate this "file" was a directory. The file then contained the list of files and directories within it. Since each directory is flagged as "logged", when a directory becomes logged we store it in memory and point to it.

    ' This type can't be bigger than 48 bytes. This way we have a 1-1 mapping between the DirEntry and 
    ' string bank.
    TYPE DirEntry
        ' Stores the visual flags of a directory (1-byte)
        Flags AS UBYTE

        ' This is effectively the offset into the bank where the string is stored. (2-byte)
        Name AS PTR STRING

        ' Child directory pointers (32-bytes)
        ChildDirectories AS PTR UBYTE

    END TYPE

    ' A byte can map 8 entries. For 170 entries we need 22 bytes to store the flags. We can store the flags in the same bank as the strings

    'DIM DirEntryBitmap[21] AS UBYTE
    'DIM DirEntry[169] AS DirEntry

    ''' Clears the memory bank used for directory entries.
    SUB Initialize()
    
        cx16.push_rambank(BANK_DIR_ENTRIES)
        BitmapAllocator.SetLocation(ADDR_DIRENTRIES_BITMAP, 29)
        BitmapAllocator.Clear()
        cx16.pop_rambank()

    END SUB

    ''' Creates a new entry for the directory.\
    ''' **Returns**: A pointer to the newly created `DirEntry` instance.
    FUNCTION CreateDirEntry() AS PTR DirEntry

        cx16.push_rambank(BANK_DIR_ENTRIES)

        BitmapAllocator.SetLocation(ADDR_DIRENTRIES_BITMAP, 29)
        
        DIM index AS UBYTE = BitmapAllocator.Allocate()

        DIM entry AS PTR DirEntry = BitmapAllocator.GetMemoryAddressOfIndex(index, TYPE_SIZE_DIRENTRY) + ADDR_DIRENTRIES_DATA

BREAKPOINT

        entry.Flags = 2
        entry.Name = $0101
        sys.memset(entry + 3, TYPE_SIZE_DIRENTRY AS UWORD, 1)
        
        cx16.pop_rambank()

        RETURN entry

    END FUNCTION

    FUNCTION GetDirEntrySize() AS UBYTE
        RETURN 35
    END FUNCTION

    ' TODO: Rewrite
    SUB ClearDirEntry(entry AS PTR DirEntry)

        entry^^.Flags = 0
        entry^^.Name = 0
        entry^^.ChildDirectories = 0

    END SUB

    SUB SetBank()
        cx16.push_rambank(BANK_DIR_ENTRIES)
    END SUB

    SUB UnsetBank()
        cx16.pop_rambank()
    END SUB

    ' FUNCTION CreateDirectoryEntry() AS PTR DirEntry

    ' END FUNCTION

END MODULE

''' Maps a one or more bytes of memory as a bitmap to track which entries are reserved. Each bit represents whether a corresponding entry is reserved or not.
''' To use, follow these instructions:
''' 1. Call `SetLocation` to set the starting memory address and size of the bitmap (in bytes).
''' 1. Call `Clear` to initialize the bitmap, marking all entries as free (0).
''' 2. Call `Allocate` to reserve and return the next free index.
''' 3. Call `Release` with the index to free a previously reserved entry.
MODULE BitmapAllocator

    ' TODO:
    ' - How do we detect when full?

    CONST BITMAP_EMPTY AS UBYTE = %0000_0000
    CONST BITMAP_FULL AS UBYTE  = %1111_1111
    CONST BITMAP_1 AS UBYTE     = %0000_0001
    CONST BITMAP_2 AS UBYTE     = %0000_0010
    CONST BITMAP_3 AS UBYTE     = %0000_0100
    CONST BITMAP_4 AS UBYTE     = %0000_1000
    CONST BITMAP_5 AS UBYTE     = %0001_0000
    CONST BITMAP_6 AS UBYTE     = %0010_0000
    CONST BITMAP_7 AS UBYTE     = %0100_0000
    CONST BITMAP_8 AS UBYTE     = %1000_0000

    DIM m_currentSize AS UBYTE
    DIM m_currentLocation AS PTR UBYTE

    SUB SetLocation(loc AS PTR UBYTE, size AS UBYTE)

        m_currentLocation = loc
        m_currentSize = size

    END SUB

    ' Calculates the memory address of an object in the bitmap.
    FUNCTION GetMemoryAddressOfIndex(index AS UBYTE, objectSize AS UBYTE) AS UWORD
        RETURN index AS UWORD * objectSize AS UWORD
    END FUNCTION

    ''' Clears the bitmap, marking all entries as free (0).
    SUB Clear()

        ALIAS originalLocation = SharedVars.uword1
        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        REPEAT m_currentSize
            poke(m_currentLocation, 0)
            m_currentLocation++
        END REPEAT

    END SUB

    ''' Prints the bitmap for debugging purposes, showing the memory address and value of each byte in the bitmap.
    SUB PrintBitmap()

        ALIAS originalLocation = SharedVars.uword1
        ALIAS locationValue = SharedVars.ubyte1
        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        REPEAT m_currentSize

            locationValue = peek(m_currentLocation)
            txt.print_uwhex(m_currentLocation, TRUE) : txt.print(": ") : txt.print_ubbin(locationValue, TRUE) : txt.print("\n")
            m_currentLocation++

        END REPEAT

    END SUB

    ''' Reserves AND returns the record index (0-based) of the NEXT free position IN the bitmap.
    FUNCTION Allocate() AS UBYTE

        ALIAS originalLocation = SharedVars.uword1
        ALIAS locationValue = SharedVars.ubyte1
        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        REPEAT m_currentSize

            locationValue = peek(m_currentLocation)

            IF locationValue == BITMAP_FULL THEN
                m_currentLocation++

            ELSEIF locationValue == BITMAP_EMPTY OR locationValue BITAND BITMAP_1 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_1)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 0

            ELSEIF locationValue BITAND BITMAP_2 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_2)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 1

            ELSEIF locationValue BITAND BITMAP_3 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_3)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 2

            ELSEIF locationValue BITAND BITMAP_4 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_4)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 3

            ELSEIF locationValue BITAND BITMAP_5 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_5)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 4

            ELSEIF locationValue BITAND BITMAP_6 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_6)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 5

            ELSEIF locationValue BITAND BITMAP_7 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_7)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 6
                
            ELSEIF locationValue BITAND BITMAP_8 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_8)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 7

            END IF

        END REPEAT

        RETURN 0

    END FUNCTION

    ''' Frees the position in the bitmap corresponding to the given index, marking it as available (0).
    SUB Release(index AS UBYTE)
    
        ALIAS originalLocation = SharedVars.uword1
        ALIAS locationValue = SharedVars.ubyte1
        ALIAS remainder = SharedVars.ubyte2

        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        m_currentLocation += index / 8
        remainder = index MOD 8
        locationValue = peek(m_currentLocation)

        SELECT CASE remainder
            CASE 0 : poke(m_currentLocation, locationValue BITAND (BITMAP_FULL - BITMAP_1))
            CASE 1 : poke(m_currentLocation, locationValue BITAND (BITMAP_FULL - BITMAP_2))
            CASE 2 : poke(m_currentLocation, locationValue BITAND (BITMAP_FULL - BITMAP_3))
            CASE 3 : poke(m_currentLocation, locationValue BITAND (BITMAP_FULL - BITMAP_4))
            CASE 4 : poke(m_currentLocation, locationValue BITAND (BITMAP_FULL - BITMAP_5))
            CASE 5 : poke(m_currentLocation, locationValue BITAND (BITMAP_FULL - BITMAP_6))
            CASE 6 : poke(m_currentLocation, locationValue BITAND (BITMAP_FULL - BITMAP_7))
            CASE 7 : poke(m_currentLocation, locationValue BITAND (BITMAP_FULL - BITMAP_8))
        END SELECT

    END SUB

    /'
    SUB TestAllocator()
    
        txt.print("\n\ntesting bitmap allocator\n")
        txt.print("========================\n")
        DirectoryManager.SetBank()

        txt.print("\nconfigure bitmap for 3 segments\nand print current memory there\n")
        BitmapAllocator.SetLocation(DirectoryManager.ADDR_BANKED_MEM, 3)
        BitmapAllocator.PrintBitmap()

        txt.print("\nclearing bitmap\n")
        BitmapAllocator.Clear()
        BitmapAllocator.PrintBitmap()

        REPEAT 3
            
            txt.print("\nallocating 5 spots\n")

            REPEAT 5
                VOID BitmapAllocator.Allocate()
            END REPEAT

            BitmapAllocator.PrintBitmap()

        END REPEAT

        txt.print("\nrelease bitmap index 4 and 10\n")
        BitmapAllocator.Release(4)
        BitmapAllocator.Release(10)
        BitmapAllocator.PrintBitmap()

        txt.print("\ntesting allocate another\n")
        VOID BitmapAllocator.Allocate()
        BitmapAllocator.PrintBitmap()

        txt.print("\ntesting allocate another\n")
        VOID BitmapAllocator.Allocate()
        BitmapAllocator.PrintBitmap()

        txt.print("\ntesting allocate another\n")
        VOID BitmapAllocator.Allocate()
        BitmapAllocator.PrintBitmap()

        DirectoryManager.UnsetBank()

    END SUB
    '/

END MODULE

MODULE Flagging

    CONST flag_IsExpanded AS UBYTE = 1
    CONST flag_HasSubDirs AS UBYTE = 2
    CONST flag_IsVisible AS UBYTE = 4
    CONST flag_IsLogged AS UBYTE = 8
    CONST flag_IsLastChild AS UBYTE = 16

    SUB PrintStatus(flags AS UBYTE)

        txt.print("\n\nchecking: ")
        txt.print_ub(flags)
        IF flags BITAND flag_IsExpanded == flag_IsExpanded THEN txt.print("\nexpanded")
        IF flags BITAND flag_HasSubDirs == flag_HasSubDirs THEN txt.print("\nhas subdirectories")
        IF flags BITAND flag_IsVisible == flag_IsVisible THEN txt.print("\nvisible")
        IF flags BITAND flag_IsLogged == flag_IsLogged THEN txt.print("\nlogged")

        IF flags = 0 THEN txt.print("\nno flags set")

    END SUB

END MODULE

MODULE SharedVars

    DIM ubyte1 AS UBYTE
    DIM ubyte2 AS UBYTE
    DIM uword1 AS UWORD
    DIM uword2 AS UWORD

END MODULE