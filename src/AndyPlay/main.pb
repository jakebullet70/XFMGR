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
IMPORT bitmapping_singlebank

MODULE main

    SUB start()
        DirectoryManager.Initialize()

        DIM index AS UBYTE = 1
        REPEAT 5

            ' Reserve a directory entry (This push/pop the bank for you)
            DIM entry1 AS PTR DirectoryManager.DirEntry = DirectoryManager.CreateDirEntry()

            ' To edit a directory entry, have to work in the correct bank
            DirectoryManager.PushBank()

            entry1.Flags = index+1

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
        
        entry1 = DirectoryManager.GetDirEntry(3)
        
        txt.print("address ") : txt.print_uwhex(entry1, TRUE) : txt.print("\n")
        txt.print("flags: ") : txt.print_ub(entry1.Flags) : txt.print("\n")
        txt.print("index: ") : txt.print_ub(entry1.NameIndex) : txt.print("\n")

        txt.print("reset directory entry\n")
        DirectoryManager.ClearDirEntry(entry1)

        txt.print("address ") : txt.print_uwhex(entry1, TRUE) : txt.print("\n")
        txt.print("flags: ") : txt.print_ub(entry1.Flags) : txt.print("\n")
        txt.print("index: ") : txt.print_ub(entry1.NameIndex) : txt.print("\n")

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

        ' This is the index in the strings bitmap where the name lives (1-byte)
        NameIndex AS UBYTE

        ' Child directory pointers (33-bytes)
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

        ' String data is going to use a different bank, but it's managed the same
        PushStringsBank()
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

        ' Set the nameindex
        entryAddress[1] = index

        PopBank()

        ' Handle the strings bank too.
        ' Since strings are going to be allocated in the exact same way, this is easy
        ' for the bitmap allocator to work in two different banks. No need to SetLocation
        ' on the bitmap because the address' are the same, being that they map to banked memory
        ' will be laid out exactly the same as DirEntry is. Strings will be up to 35 bytes in 
        ' size, the same as a DirEntry
        PushStringsBank()
        
        ' Allocate an item
        BitmapAllocator.Reserve(index)

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
        DIM nameIndex AS UBYTE = entry.NameIndex
        sys.memset(entry, TYPE_SIZE_DIRENTRY AS UWORD, 0)
        entry.NameIndex = nameIndex
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

    SUB PushStringsBank()
        cx16.push_rambank(BANK_DIR_STRINGS)
    END SUB

    SUB SetStringsBank()
        cx16.rambank(BANK_DIR_STRINGS)
    END SUB

END MODULE

MODULE DirectoryStrings



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
