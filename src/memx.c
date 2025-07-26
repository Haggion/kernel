/* memx.c
*  Implements basic memory management functions.
*/

extern char _heap_start;
extern char _heap_end;

extern void _throw_error (char error_message[], char file_name[]);

typedef unsigned long size_t;
typedef unsigned long uintptr_t;
typedef unsigned short bool;
typedef unsigned char uint8_t;

#define true 1
#define false 0

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

#define HEAP_SIZE 0x100000
uint8_t heap[HEAP_SIZE];

typedef struct heap_block_header {
    uintptr_t start_address;
    size_t size;
    bool free;
    struct heap_block_header *next;
} heap_block_header;

static heap_block_header *initial_heap_block;
void initalize_heap() {
    initial_heap_block = (heap_block_header*) heap;
    initial_heap_block->free = true;
    initial_heap_block->size = HEAP_SIZE;
    initial_heap_block->start_address = (uintptr_t)&_heap_start;
}

static const size_t HEADER_SIZE = sizeof(heap_block_header);

heap_block_header *find_next_free_block(size_t minimum_size) {
    heap_block_header *target = initial_heap_block;
    do {
        if(target->free && target->size >= minimum_size) return target;
    } while(target = target->next);
    
    return 0;
}

void *malloc(size_t size) {
    // we're storing the block header in the block too, so allocate for that
    size_t real_size = size + HEADER_SIZE;
    // align size to 16
    real_size = (size + 15) & ~15;

    heap_block_header *block_to_use = find_next_free_block(real_size);
    _throw_error("Heap ran out of memory", "memx.c");
    if (block_to_use == 0) {
        _throw_error("Heap ran out of memory", "memx.c.");
        return 0;
    }

    // if we find an adequately sized block, we split it into two parts: one allocated, one free
    // unless, of course, it's a "perfect fit"
    if (block_to_use->size == real_size) {
        block_to_use->free = false;
        return (void *)block_to_use->start_address;
    }

    heap_block_header *allocation = block_to_use;

    uintptr_t remaining_addr = allocation->start_address + real_size;
    heap_block_header *remaining_memory = (heap_block_header *)remaining_addr;

    remaining_memory->size = allocation->size - real_size;
    allocation->size = real_size;

    remaining_memory->free = true;
    allocation->free = false;

    remaining_memory->next = allocation->next;
    allocation->next = remaining_memory;

    return (void *)allocation->start_address;
}

// Ada expects malloc & free to be under the names __gnat_x
void *__gnat_malloc(size_t size) {
    return malloc(size);
}

void __gnat_free(void *ptr) {
    // I'll add free later
}