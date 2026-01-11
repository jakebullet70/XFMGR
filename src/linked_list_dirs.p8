

dirs_cache {
    struct Entry {
        ^^Entry next          ; Next entry in the list
        ^^Entry prev          ; Previous entry in the list
        str name              ; Name (key)
        bool is_dir
        bool is_tagged
        uword blocks
        ubyte rec_num
    }

    ^^Entry head = 0                       ; Head of the doubly linked list
    ^^Entry tail = 0                       ; Tail of the doubly linked list

    ubyte num_files = 0                    ; Number of entries

    const ubyte FILE_NAME_SIZE = 40
    const bool FILE_ENTRY = false
    const bool NOT_TAGGED = false
    const ubyte LEFT_COL = 2
    const ubyte TOP_ROW = 6
    
    ;--- vars for movement
    ubyte top_index = 0
    ubyte selected_line,num_visible_files
    ubyte max_lines = txt.height() - 11

    ^^Entry current

    sub init() { }



}



arena_dirs {
    ; Simple arena allocator
    uword buffer = memory("a_dirs", 3200, 0)
    uword next = buffer

    sub alloc(ubyte size) -> uword {
        defer next += size
        return next
    }

    sub free_all() {
        ; cannot free individual allocations only the whole arena at once
        ; UNTESTED!!! - assuming this resets the pointer to the top
        next = buffer
    }
}


