/* memx.c
*  Implements basic memory management functions.
*/

extern char _heap_start;
extern char _heap_end;

typedef unsigned long size_t;
typedef unsigned long uintptr_t;
typedef unsigned short bool;

void *memcpy(void *destination, const void *source, size_t size) {
    unsigned char *d = destination;
    const unsigned char *s = source;

    // copy everything in source to destination
    while (size--) 
        *d++ = *s++;
    
    return destination;
}

void *memset(void *destination, int ch, size_t size) {
    unsigned char *pointer = destination;

    // sets the size next bytes of destination to ch
    while (size--) 
        *pointer++ = (unsigned char)ch;
    
    return destination;
}


void *malloc(size_t size) {
    static uintptr_t heap_top = (uintptr_t)&_heap_start;
    static const uintptr_t heap_max = (uintptr_t)&_heap_end;

    // heap addresses need to be aligned to 16 
    heap_top = (heap_top + 15) & ~15;
    // align size too, just in case
    size = (size + 15) & ~15;

    const uintptr_t new_heap_top = heap_top + (uintptr_t) size;
    if(new_heap_top > heap_max) {
        // ret null;
        return 0;
    }

    void *block_start = (void *)heap_top;
    heap_top = new_heap_top;

    return block_start;
}

// Ada expects malloc & free to be under the names __gnat_x
void *__gnat_malloc(size_t size) {
    return malloc(size);
}

void __gnat_free(void *ptr) {
    // I'll add free later
}