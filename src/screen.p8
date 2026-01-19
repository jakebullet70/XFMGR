; // =============================================================================
; // Screen store/restore module
; // TODO:
; //   - I used the ringbuffer to store the data, really as a way to explore how
; //     to use it. honestly, we don't need the overkill on that. We can just
; //     do it manually. I had stolen the code in the repeat loops from the
; //     ringbuffer module and modified because it normally swaps banks back and
; //     forth which we don't want here.
; // =============================================================================

%import buffers

screen {

    const uword VERA_TXTSCREEN = $b000
    const ubyte SCREENDUMP_BANK1 = 62
    const ubyte SCREENDUMP_BANK2 = 63

    sub store() {

        cx16.vaddr_autoincr(1, VERA_TXTSCREEN, 0, 1)

        ringbuffer.init(SCREENDUMP_BANK1)

        ;// Store existing bank
        sys.push(cx16.getrambank())

        ;// Start with first 8kb
        cx16.rambank(SCREENDUMP_BANK1)
        
        uword loopSize = ringbuffer.tail - ringbuffer.head

        repeat loopSize {
            ubyte dataValue = cx16.VERA_DATA0

            @(ringbuffer.head) = dataValue

            ringbuffer.fill++
            ringbuffer.inc_head()
        }

        ;// Second 8kb
        ringbuffer.init(SCREENDUMP_BANK2)
        cx16.rambank(SCREENDUMP_BANK2)

        repeat loopSize {
            dataValue = cx16.VERA_DATA0

            @(ringbuffer.head) = dataValue

            ringbuffer.fill++
            ringbuffer.inc_head()
        }

        ;// END LOOP
        cx16.rambank(sys.pop())
    }

    sub restore() {
        cx16.vaddr_autoincr(1, VERA_TXTSCREEN, 0, 1)

        ringbuffer.init(SCREENDUMP_BANK1)

        ;// Store existing bank
        sys.push(cx16.getrambank())

        ;// Start with first 8kb
        cx16.rambank(SCREENDUMP_BANK1)
        
        uword loopSize = ringbuffer.tail - ringbuffer.head

        repeat loopSize {
            ubyte dataValue = @(ringbuffer.head)

            cx16.VERA_DATA0 = dataValue

            ringbuffer.fill++
            ringbuffer.inc_head()
        }

        ;// Second 8kb
        ringbuffer.init(SCREENDUMP_BANK2)
        cx16.rambank(SCREENDUMP_BANK2)

        repeat loopSize {
            dataValue = @(ringbuffer.head)

            cx16.VERA_DATA0 = dataValue

            ringbuffer.fill++
            ringbuffer.inc_head()
        }

        ;// END LOOP
        cx16.rambank(sys.pop())
    }

}