' Thoughts by Jack Handy.. No.. Andy!
'
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



OPTION no_sysinit
ZEROPAGE basicsafe

IMPORT textio
IMPORT conv

MODULE main

    SUB start()
        DirectoryManager.Initialize()

        DIM index AS UBYTE = 1
        REPEAT 5

            ' Reserve a directory entry (This push/pop the bank for you)
            DIM entry1 AS PTR DirectoryManager.DirEntry = DirectoryManager.CreateDirEntry()

            ' To edit a directory entry, have to work in the correct bank
            DirectoryManager.PushBank()

            entry1.Name = "test"
            entry1.Flags = index

            index++
            
            ' You would normally use `entry1.ChildDirectories[0] = value` to set a one of the items, but
            ' instead here we're going to fill the entire child directory area with a value so you can
            ' see it in memory get filled.
            '          Move pointer to start of the child dirs property
            '          |
            '          |                      Length is the size of type - size of data before child dirs
            '          |                      |
            '          |                      |                             Use value 9 to fill mem, just testing
            '          |____________________  |_________________________________________________  |
            sys.memset((entry1 AS UWORD) + 3, (DirectoryManager.TYPE_SIZE_DIRENTRY - 3) AS UWORD, 9)

            ' Restore normal memory
            DirectoryManager.PopBank()

        END REPEAT

        ' Again, to read the directory entry, have to work in the correct bank
        DirectoryManager.PushBank()
        
        entry1 = DirectoryManager.GetDirEntry(2)
        
        txt.print("address ") : txt.print_uwhex(entry1, TRUE) : txt.print("\n")
        txt.print("flags: ") : txt.print_ub(entry1.Flags) : txt.print("\n")
        txt.print("name: ") : txt.print(entry1.Name) : txt.print("\n")

        txt.print("reset directory entry\n")
        DirectoryManager.ClearDirEntry(entry1)

        txt.print("address ") : txt.print_uwhex(entry1, TRUE) : txt.print("\n")
        txt.print("flags: ") : txt.print_ub(entry1.Flags) : txt.print("\n")
        ' This will be garbage because the string is a pointer and was reset to 0 which points
        ' to zero page!
        txt.print("name: ") : txt.print(entry1.Name) : txt.print("\n")

        DirectoryManager.PopBank()

    END SUB

    SUB PrintMemAndValue(memoryPosition AS PTR UBYTE)
        txt.print("address ") : txt.print_uwhex(memoryPosition, TRUE) : txt.print(" is ") : txt.print_ub(memoryPosition^^) : txt.print("\n")
    END SUB

END MODULE

MODULE DirectoryManager
    ''' The size of the DirEntry type in bytes.
    CONST TYPE_SIZE_DIRENTRY AS UBYTE = 35 '$23

    ''' The size of the bitmap for DirEntry items.
    CONST BITMAP_SIZE AS UBYTE = 29 '$1D

    ''' The memory location of the bitmap representing DirEntry.
    CONST ADDR_DIRENTRIES_BITMAP AS UWORD = $A000

    ''' The memory location of the DirEntry instances.
    CONST ADDR_DIRENTRIES_DATA AS UWORD = $A000 + BITMAP_SIZE ' Root of bank + 1 entry that holds bitmap

    ''' The number of entries we can have in the bank.
    CONST MAX_DIR_ENTRIES AS UBYTE = 8 * BITMAP_SIZE

    ''' The bank number where the bitmap and DirEntry instances are stored.
    CONST BANK_DIR_ENTRIES AS UBYTE = 40 '$28

    CONST BANK_DIR_STRINGS AS UBYTE = 41 '$29

    ' This type can't be bigger than 48 bytes. This way we have a 1-1 mapping between the DirEntry and 
    ' string bank.
    TYPE DirEntry '(35 bytes)
        ' Stores the visual flags of a directory (1-byte)
        Flags AS UBYTE

        ' This is effectively the offset into the bank where the string is stored. (2-byte)
        Name AS STRING

        ' Child directory pointers (32-bytes)
        ChildDirectories AS PTR UBYTE

    END TYPE

    ''' Resets the bitmap used for directory entries.
    '''
    ''' **Note**: Pushes and pops the memory bank for you.
    SUB Initialize()
    
        PushBank()
        BitmapAllocator.SetLocation(ADDR_DIRENTRIES_BITMAP, BITMAP_SIZE)
        BitmapAllocator.Clear()
        PopBank()

    END SUB

    ''' Creates a new entry for the directory.\
    ''' **Returns**: A pointer to the newly created `DirEntry` instance.
    '''
    ''' **Note**: Pushes and pops the memory bank for you.
    FUNCTION CreateDirEntry() AS PTR DirEntry

        PushBank()

        ' Map the bitmap to the ram bank area
        BitmapAllocator.SetLocation(ADDR_DIRENTRIES_BITMAP, BITMAP_SIZE)
        
        ' Allocate an item
        DIM index AS UBYTE = BitmapAllocator.Allocate()

        ' Get the memory address of the index (after the bitmap area)
        DIM entryAddress AS UWORD = BitmapAllocator.GetMemoryAddressOfIndex(index, TYPE_SIZE_DIRENTRY) + ADDR_DIRENTRIES_DATA

        ' Clear the memory of the entry
        sys.memset(entryAddress, TYPE_SIZE_DIRENTRY AS UWORD, 0)

        PopBank()

        RETURN entryAddress

    END FUNCTION

    ''' Calculates the memory address of a `DirEntry` instance based on its index in the bitmap and returns it as a pointer.
    '''
    ''' **Note**: Memory bank isn't required.
    FUNCTION GetDirEntry(index AS UBYTE) AS PTR DirEntry

        ' Get the memory address of the index (after the bitmap area)
        DIM entryAddress AS UWORD = BitmapAllocator.GetMemoryAddressOfIndex(index, TYPE_SIZE_DIRENTRY) + ADDR_DIRENTRIES_DATA

        RETURN entryAddress

    END FUNCTION

    ''' Clears the memory of a `DirEntry` instance, effectively resetting its values.
    '''
    ''' **Note**: _Doesn't_ push or pop the memory bank.
    SUB ClearDirEntry(entry AS PTR DirEntry)
        sys.memset(entry, TYPE_SIZE_DIRENTRY AS UWORD, 0)
    END SUB

    SUB PushBank()
        cx16.push_rambank(BANK_DIR_ENTRIES)
    END SUB

    SUB PopBank()
        cx16.pop_rambank()
    END SUB

    SUB SetBank()
        cx16.rambank(BANK_DIR_ENTRIES)
    END SUB

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