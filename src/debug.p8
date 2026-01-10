%import textio

; from good guy gillham - https://github.com/gillham/prog8libs/tree/main/assert

monitor {
    sub open() {
        %asm {{
            brk
        }}
    }
}

debug {
    const ubyte EQ = 1
    const ubyte NE = 2
    const ubyte GT = 3
    const ubyte GE = 4
    const ubyte LT = 5
    const ubyte LE = 6

    const ubyte col = 23
    ubyte row = 0

    sub init(ubyte yrow) {
        row = yrow
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


    sub say2(str msg, ubyte num) {
        str tmp = "?"*40
        concat_strings(msg,conv.str_ub(num),tmp)
        say(tmp)
    }


    sub say(str msg) {
        txt.plot(col,row)
        txt.print(" "*40)
        txt.plot(col,row)
        txt.print("[")
        txt.plot(col+1,row)
        txt.print(msg)
        txt.plot(col+40,row)
        txt.print("]")
    }

    sub assert(uword one, uword two, ubyte check, str msg) -> bool {
        when check {
            EQ -> if one == two return true
            NE -> if one != two return true
            GT -> if one > two return true
            GE -> if one >= two return true
            LT -> if one < two return true
            LE -> if one <= two return true
            else -> {
                txt.print("\ninvalid assert check\n")
            }
        }
        txt.plot(row,col)
        txt.print("\nassert failure: ")
        txt.print_uwhex(one, true)
        when check {
            EQ -> txt.print(" == ")
            NE -> txt.print(" != ")
            GT -> txt.print(" > ")
            GE -> txt.print(" >= ")
            LT -> txt.print(" < ")
            LE -> txt.print(" <= ")
        }
        txt.print_uwhex(two, true)
        txt.nl()
        txt.print(msg)
        txt.nl()
        txt.print("halting. use the debugger.")
        txt.print("\npress 'm' for monitor. any other continues\n")
        if txt.waitkey() != 'm' return false
        monitor.open()
        repeat {}
    }
}
