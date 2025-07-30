/* memx.c
*  Implements basic memory management functions.
*/

extern char _heap_start;
extern char _heap_end;

extern void _throw_error (char error_message[], char file_name[]);
extern void _put_cstring (char line[]);
extern void _put_int (long num);

typedef unsigned long size_t;
typedef unsigned long uintptr_t;
typedef unsigned short bool;
typedef unsigned char uint8_t;

#define true 1
#define false 0
#define null 0

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

void print_heap() {
    _put_cstring("===== HEAP START =====\n");
    heap_block_header *curr = initial_heap_block;
    do {
        _put_cstring("Block: ");
        _put_int((long)curr->start_address);
        _put_cstring(" size: ");
        _put_int(curr->size);
        _put_cstring(curr->free ? " FREE\n" : " USED\n");
    } while (curr = curr->next);
    _put_cstring("===== HEAP END =====\n");
}

static const size_t HEADER_SIZE = sizeof(heap_block_header);

heap_block_header *find_next_free_block(size_t minimum_size) {
    heap_block_header *target = initial_heap_block;
    do {
        if(target->free && target->size >= minimum_size) return target;
    } while(target = target->next);
    
    return null;
}

void *malloc(size_t size) {
    // we're storing the block header in the block too, so allocate for that
    size_t real_size = size + HEADER_SIZE;
    // align size to 16
    real_size = (real_size + 15) & ~15;

    heap_block_header *block_to_use = find_next_free_block(real_size);
    
    if (block_to_use == 0) {
        _throw_error("Heap ran out of memory", "memx.c");
        return null;
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

    remaining_memory->start_address = remaining_addr;

    return (void *)(allocation->start_address + HEADER_SIZE);
}

void free(void *pointer) {
    heap_block_header *target = initial_heap_block;
    heap_block_header *last_in_use_block = null;

    uintptr_t target_address = (uintptr_t)pointer;
    
    do {
        if (target->start_address >= target_address) {
            break;
        }
        
        if (!target->free) last_in_use_block = target;
    } while (target = target->next);

    if (target->start_address != target_address) {
        _throw_error("Address doesn't point to start of block", "memx.c");
        return;
    }

    target->free = true;

    // this combines all adjacent free blocks to the left of the block we are freeing
    if(last_in_use_block != null) {
        target->start_address = last_in_use_block->start_address + (uintptr_t) last_in_use_block->size;
        last_in_use_block->next = target;
    } else {
        // in this case, stretch block to heap start
        target->start_address = (uintptr_t) &_heap_start;
        initial_heap_block = target;
    }

    // if is last block in heap, stretch to fill rest
    if (target->next == null) {
        target->size = (size_t) (_heap_end - target->start_address);
        return;
    }

    // this combines all adjacent free blocks to the right of the block we are freeing

    heap_block_header *ending_block = target;

    while (ending_block = ending_block->next) {
        if (!ending_block->free){
            break;
        }
    }
    
    // if there were free blocks all the way until the end, then just stretch to fill rest
    if  (ending_block == null) {
        target->size = (size_t) ((uintptr_t) &_heap_end - target->start_address);
        target->next = null;
        return;
    }

    // have block stretch until free block reached
    target->size = (size_t) (ending_block->start_address - target->start_address);
    target->next = ending_block;
}

// Ada expects malloc & free to be under the names __gnat_x
void *__gnat_malloc(size_t size) {
    return malloc(size);
}

void __gnat_free(void *pointer) {
    return free(pointer);
}