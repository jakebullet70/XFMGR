' // =============================================================================
' // Screen store/restore module
' // TODO:
' //   - I used the ringbuffer to store the data, really as a way to explore how
' //     to use it. honestly, we don't need the overkill on that. We can just
' //     do it manually. I had stolen the code in the repeat loops from the
' //     ringbuffer module and modified because it normally swaps banks back and
' //     forth which we don't want here.
' // =============================================================================

Import buffers

Module screen

    Const VERA_TXTSCREEN As Uword = $b000
    Const SCREENDUMP_BANK1 As Ubyte = 62
    Const SCREENDUMP_BANK2 As Ubyte = 63

    Sub store()

        '--- re-use global vars
        Alias loopSize = main.uword_tmp1
        Alias dataValue = main.x

        cx16.vaddr_autoincr(1, VERA_TXTSCREEN, 0, 1)

        ringbuffer.init(SCREENDUMP_BANK1)

        ' Store existing bank
        sys.push(cx16.getrambank())

        ' Start with first 8kb
        cx16.rambank(SCREENDUMP_BANK1)
        
        loopSize = ringbuffer.tail - ringbuffer.head

        Repeat loopSize
        
            dataValue = cx16.VERA_DATA0

            @(ringbuffer.head) = dataValue

            ringbuffer.fill++
            ringbuffer.inc_head()

        End Repeat

        ' Second 8kb
        ringbuffer.init(SCREENDUMP_BANK2)
        cx16.rambank(SCREENDUMP_BANK2)

        Repeat loopSize
        
            dataValue = cx16.VERA_DATA0

            Poke ringbuffer.head, dataValue

            ringbuffer.fill++
            ringbuffer.inc_head()
        
        End Repeat

        ' Restore ram bank
        cx16.rambank(sys.pop())
    End Sub

    Sub restore()

        ' Use global vars
        Alias loopSize = main.uword_tmp1
        Alias dataValue = main.x

        cx16.vaddr_autoincr(1, VERA_TXTSCREEN, 0, 1)

        ringbuffer.init(SCREENDUMP_BANK1)

        ' Store existing bank
        sys.push(cx16.getrambank())

        ' Start with first 8kb
        cx16.rambank(SCREENDUMP_BANK1)
        
        loopSize = ringbuffer.tail - ringbuffer.head

        Repeat loopSize

            dataValue = Peek(ringbuffer.head)

            cx16.VERA_DATA0 = dataValue

            ringbuffer.fill++
            ringbuffer.inc_head()
        
        End Repeat

        ' Second 8kb
        ringbuffer.init(SCREENDUMP_BANK2)
        cx16.rambank(SCREENDUMP_BANK2)

        Repeat loopSize

            dataValue = Peek(ringbuffer.head)

            cx16.VERA_DATA0 = dataValue

            ringbuffer.fill++
            ringbuffer.inc_head()

        End Repeat

        ' Restore ram bank
        cx16.rambank(sys.pop())
    End Sub
End Module