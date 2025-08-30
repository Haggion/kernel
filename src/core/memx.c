/* memx.c
*  Implements basic memory management functions.
*/

extern char _heap_start;
extern char _heap_end;

extern void _throw_error (char error_message[], char file_name[]);
extern void _put_cstring (char line[]);
extern void _put_int (long num);

typedef unsigned long long size_t;
typedef unsigned long long uintptr_t;
typedef unsigned char bool;
typedef unsigned char uint8_t;

// if larger things need to be allocated, change typedef
typedef unsigned block_size;
// if heapsize changes, change typedef
typedef unsigned block_offset;

const uintptr_t heap_start = (uintptr_t) &_heap_start;

#define true 1
#define false 0
#define null 0

#define DEBUGGING false

size_t align16(size_t x) {
    return ((x + 15) & ~((size_t) 15));
}

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

#define HEADER_MAGIC 0xC0FFEE

typedef struct heap_block_header {
    block_offset start_offset;
    block_size size;
    bool free;
    struct heap_block_header *next;
    // having a magic number for heap verification is
    // useful for debugging, but costly in storage otherwise
    #if DEBUGGING == true
        unsigned magic;
    #endif
} heap_block_header;

static const block_size HEADER_SIZE = sizeof(heap_block_header);
static heap_block_header *initial_heap_block;

void initalize_heap() {
    uintptr_t start = align16(heap_start + HEADER_SIZE) - HEADER_SIZE;
    uintptr_t end = (uintptr_t)&_heap_end;

    initial_heap_block = (heap_block_header*)start;
    initial_heap_block->free = true;
    initial_heap_block->size = (block_size)(end - start);
    initial_heap_block->start_offset = (block_offset)(start - heap_start);
    initial_heap_block->next = null;
    #if DEBUGGING == true
        initial_heap_block->magic = HEADER_MAGIC;
    #endif
}

void print_heap() {
    if (initial_heap_block == null) {
        _put_cstring("==== MISSING HEAP ====\n\r");
        return;
    }

    _put_cstring("===== HEAP START =====\n\r");
    heap_block_header *curr = initial_heap_block;
    do {
        _put_cstring("Block: ");
        _put_int((long)curr->start_offset);
        _put_cstring(" size: ");
        _put_int(curr->size);
        _put_cstring(curr->free ? " FREE\n\r" : " USED\n\r");
    } while (curr = curr->next);
    _put_cstring("===== HEAP END =====\n\r");
}

heap_block_header *find_next_free_block(block_size minimum_size) {
    heap_block_header *target = initial_heap_block;

    if (target == null) return null;

    do {
        if(target->free && target->size >= minimum_size) return target;
    } while(target = target->next);
    
    return null;
}

void *malloc(block_size size) {
    // we're storing the block header in the block too, so allocate for that
    block_size real_size = size + HEADER_SIZE;
    // align size to 16
    real_size = align16(real_size);

    heap_block_header *block_to_use = find_next_free_block(real_size);
    
    if (block_to_use == null) {
        _throw_error("Heap ran out of memory", "memx.c");
        return null;
    }

    #if DEBUGGING == true
        if (block_to_use->magic != HEADER_MAGIC) {
            _throw_error("Block found corrupted before allocating!", "memx.c");
            return null;
        }
    #endif

    // if we find an adequately sized block, we split it into two parts: one allocated, one free -
    // unless it's a perfect fit, or the new free block would be too small to store even a header
    if (block_to_use->size - real_size < HEADER_SIZE) {
        block_to_use->free = false;
        return (void *)(block_to_use->start_offset + HEADER_SIZE + heap_start);
    }

    heap_block_header *allocation = block_to_use;

    uintptr_t remaining_addr = allocation->start_offset + real_size + heap_start;
    heap_block_header *remaining_memory = (heap_block_header *)remaining_addr;

    remaining_memory->size = allocation->size - real_size;
    allocation->size = real_size;

    remaining_memory->free = true;
    allocation->free = false;

    remaining_memory->next = allocation->next;
    allocation->next = remaining_memory;

    remaining_memory->start_offset = remaining_addr - heap_start;

    #if DEBUGGING == true
        remaining_memory->magic = HEADER_MAGIC;
    #endif

    return (void *)(allocation->start_offset + HEADER_SIZE + heap_start);
}

void free(void *pointer) {
    if (pointer == null) return;
    if (initial_heap_block == null) return;

    heap_block_header *target = initial_heap_block;
    heap_block_header *last_block = null;

    uintptr_t target_address = (uintptr_t)pointer - HEADER_SIZE - heap_start;
    
    do {
        if (target->start_offset >= target_address) {
            break;
        }
        
        last_block = target;
    } while (target = target->next);

    if (target == null || target->start_offset != target_address) {
        _throw_error("Address doesn't point to start of block", "memx.c");
        return;
    }

    #if DEBUGGING == true
        if (target->magic != HEADER_MAGIC) {
            _throw_error("Block found corrupted before freeing!", "memx.c");
        }
    #endif

    if (target->free) {
        _throw_error("Target block was already free!", "memx.c");
        return;
    }

    target->free = true;

    // merge adjacent blocks
    if (last_block != null && last_block->free &&
        last_block->start_offset + last_block->size == target->start_offset) {
        last_block->size += target->size;
        last_block->next  = target->next;
        target = last_block;
    } else if (last_block == null) {
        // if nothing to merge, stretch block to heap start
        initial_heap_block = target;
    }

    // if is last block in heap, stretch to fill rest
    if (target->next == null) {
        target->size = (block_size) ((uintptr_t) (&_heap_end - (heap_start + target->start_offset)));
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
        target->size = (block_size) ((uintptr_t) (&_heap_end - (heap_start + target->start_offset)));
        target->next = null;
        return;
    }

    // have block stretch until free block reached
    target->size = (block_size) (ending_block->start_offset - target->start_offset);
    target->next = ending_block;
}

int memcmp(const void* left, const void* right, size_t count) {
    if (count == 0) return 0;
    if (left == null || right == null) return 0;

    const unsigned char *l = (const unsigned char*)left;
    const unsigned char *r = (const unsigned char*)right;

    for (size_t i = 0; i < count; i++) {
        if (l[i] != r[i]) {
            return (int)l[i] - (int)r[i];
        }
    }

    return 0;
}

// Ada expects malloc & free to be under the names __gnat_x
void *__gnat_malloc(block_size size) {
    return malloc(size);
}

void __gnat_free(void *pointer) {
    free(pointer);
}