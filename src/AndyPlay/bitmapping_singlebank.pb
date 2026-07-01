IMPORT textio

''' Maps a one or more bytes of memory as a bitmap to track which entries are reserved. Each bit represents whether a corresponding entry is reserved or not.
''' To use, follow these instructions:
''' 1. Call `SetLocation` to set the starting memory address and size of the bitmap (in bytes).
''' 1. Call `Clear` to initialize the bitmap, marking all entries as free (0).
''' 2. Call `Allocate` to reserve and return the next free index.
''' 3. Call `Release` with the index to free a previously reserved entry.
MODULE BitmapAllocator

    ' TODO:
    ' - How do we detect when full?

    CONST BITMAP_ENTRY_EMPTY AS UBYTE      = %0000_0000
    CONST BITMAP_ENTRY_FULL AS UBYTE       = %1111_1111
    CONST BITMAP_ENTRY_INDEX1 AS UBYTE     = %0000_0001
    CONST BITMAP_ENTRY_INDEX2 AS UBYTE     = %0000_0010
    CONST BITMAP_ENTRY_INDEX3 AS UBYTE     = %0000_0100
    CONST BITMAP_ENTRY_INDEX4 AS UBYTE     = %0000_1000
    CONST BITMAP_ENTRY_INDEX5 AS UBYTE     = %0001_0000
    CONST BITMAP_ENTRY_INDEX6 AS UBYTE     = %0010_0000
    CONST BITMAP_ENTRY_INDEX7 AS UBYTE     = %0100_0000
    CONST BITMAP_ENTRY_INDEX8 AS UBYTE     = %1000_0000

    CONST BITMAP_FULL AS UBYTE = 255

    DIM m_currentSize AS UBYTE
    DIM m_currentLocation AS PTR UBYTE

    DIM m_tempByte1 AS UBYTE
    DIM m_tempByte2 AS UBYTE
    DIM m_tempWord AS UWORD

    ''' Configures the bitmap allocator to target a region of memory. If that memory is new, it needs to be cleared.
    '''
    ''' **Note**: Maximum size is 255
    SUB SetLocation(loc AS PTR UBYTE, size AS UBYTE)

        m_currentLocation = loc
        m_currentSize = size

    END SUB

    ''' Calculates the memory address of a target object reserved in the bitmap.
    FUNCTION GetMemoryAddressOfIndex(index AS UBYTE, objectSize AS UBYTE) AS UWORD
        RETURN index AS UWORD * objectSize AS UWORD
    END FUNCTION

    ''' Clears the bitmap, marking all entries as free (0).
    SUB Clear()

        ALIAS originalLocation = m_tempWord
        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        REPEAT m_currentSize
            poke(m_currentLocation, 0)
            m_currentLocation++
        END REPEAT

    END SUB

    ''' Prints the bitmap for debugging purposes, showing the memory address and value of each byte in the bitmap.
    '''
    ''' **Note**: _Doesn't_ push or pop the memory bank.
    SUB PrintBitmap()

        ALIAS originalLocation = m_tempWord
        ALIAS locationValue = m_tempByte1
        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        REPEAT m_currentSize

            locationValue = peek(m_currentLocation)
            txt.print_uwhex(m_currentLocation, TRUE) : txt.print(": ") : txt.print_ubbin(locationValue, TRUE) : txt.print("\n")
            m_currentLocation++

        END REPEAT

    END SUB

    ''' Reserves AND returns the record index (0-based) of the NEXT free position IN the bitmap. Returns BITMAP_IS_FULL if there are no free positions.
    '''
    ''' **Note**: _Doesn't_ push or pop the memory bank.
    FUNCTION Allocate() AS UBYTE

        ALIAS originalLocation = m_tempWord
        ALIAS locationValue = m_tempByte1
        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        REPEAT m_currentSize

            locationValue = peek(m_currentLocation)

            IF locationValue == BITMAP_ENTRY_FULL THEN
                m_currentLocation++

            ELSEIF locationValue == BITMAP_ENTRY_EMPTY OR locationValue BITAND BITMAP_ENTRY_INDEX1 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_ENTRY_INDEX1)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 0

            ELSEIF locationValue BITAND BITMAP_ENTRY_INDEX2 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_ENTRY_INDEX2)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 1

            ELSEIF locationValue BITAND BITMAP_ENTRY_INDEX3 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_ENTRY_INDEX3)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 2

            ELSEIF locationValue BITAND BITMAP_ENTRY_INDEX4 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_ENTRY_INDEX4)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 3

            ELSEIF locationValue BITAND BITMAP_ENTRY_INDEX5 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_ENTRY_INDEX5)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 4

            ELSEIF locationValue BITAND BITMAP_ENTRY_INDEX6 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_ENTRY_INDEX6)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 5

            ELSEIF locationValue BITAND BITMAP_ENTRY_INDEX7 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_ENTRY_INDEX7)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 6
                
            ELSEIF locationValue BITAND BITMAP_ENTRY_INDEX8 == 0 THEN
                poke(m_currentLocation, peek(m_currentLocation) BITOR BITMAP_ENTRY_INDEX8)
                RETURN (m_currentLocation - originalLocation) AS UBYTE * 8 + 7

            END IF

        END REPEAT

        RETURN BITMAP_FULL

    END FUNCTION

    ''' Reserves the position in the bitmap corresponding to the given index, marking it as reserved (1).
    '''
    ''' **Note**: _Doesn't_ push or pop the memory bank.
    SUB Reserve(index AS UBYTE)
    
        ALIAS originalLocation = m_tempWord
        ALIAS locationValue = m_tempByte1
        ALIAS remainder = m_tempByte2

        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        m_currentLocation += index / 8
        remainder = index MOD 8
        locationValue = peek(m_currentLocation)

        SELECT CASE remainder
            CASE 0 : poke(m_currentLocation, locationValue BITOR BITMAP_ENTRY_INDEX1)
            CASE 1 : poke(m_currentLocation, locationValue BITOR BITMAP_ENTRY_INDEX2)
            CASE 2 : poke(m_currentLocation, locationValue BITOR BITMAP_ENTRY_INDEX3)
            CASE 3 : poke(m_currentLocation, locationValue BITOR BITMAP_ENTRY_INDEX4)
            CASE 4 : poke(m_currentLocation, locationValue BITOR BITMAP_ENTRY_INDEX5)
            CASE 5 : poke(m_currentLocation, locationValue BITOR BITMAP_ENTRY_INDEX6)
            CASE 6 : poke(m_currentLocation, locationValue BITOR BITMAP_ENTRY_INDEX7)
            CASE 7 : poke(m_currentLocation, locationValue BITOR BITMAP_ENTRY_INDEX8)
        END SELECT

    END SUB

    ''' Frees the position in the bitmap corresponding to the given index, marking it as available (0).
    '''
    ''' **Note**: _Doesn't_ push or pop the memory bank.
    SUB Release(index AS UBYTE)
    
        ALIAS originalLocation = m_tempWord
        ALIAS locationValue = m_tempByte1
        ALIAS remainder = m_tempByte2

        originalLocation = m_currentLocation
        DEFER m_currentLocation = originalLocation

        m_currentLocation += index / 8
        remainder = index MOD 8
        locationValue = peek(m_currentLocation)

        SELECT CASE remainder
            CASE 0 : poke(m_currentLocation, locationValue BITAND (BITMAP_ENTRY_FULL - BITMAP_ENTRY_INDEX1))
            CASE 1 : poke(m_currentLocation, locationValue BITAND (BITMAP_ENTRY_FULL - BITMAP_ENTRY_INDEX2))
            CASE 2 : poke(m_currentLocation, locationValue BITAND (BITMAP_ENTRY_FULL - BITMAP_ENTRY_INDEX3))
            CASE 3 : poke(m_currentLocation, locationValue BITAND (BITMAP_ENTRY_FULL - BITMAP_ENTRY_INDEX4))
            CASE 4 : poke(m_currentLocation, locationValue BITAND (BITMAP_ENTRY_FULL - BITMAP_ENTRY_INDEX5))
            CASE 5 : poke(m_currentLocation, locationValue BITAND (BITMAP_ENTRY_FULL - BITMAP_ENTRY_INDEX6))
            CASE 6 : poke(m_currentLocation, locationValue BITAND (BITMAP_ENTRY_FULL - BITMAP_ENTRY_INDEX7))
            CASE 7 : poke(m_currentLocation, locationValue BITAND (BITMAP_ENTRY_FULL - BITMAP_ENTRY_INDEX8))
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