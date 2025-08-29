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

#define true 1
#define false 0
#define null 0

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
    uintptr_t start_address;
    size_t size;
    bool free;
    struct heap_block_header *next;
    unsigned magic;
} heap_block_header;

static const size_t HEADER_SIZE = sizeof(heap_block_header);
static heap_block_header *initial_heap_block;

void initalize_heap() {
    uintptr_t start = (uintptr_t)&_heap_start;
    start = align16(start + HEADER_SIZE) - HEADER_SIZE;
    uintptr_t end = (uintptr_t)&_heap_end;

    initial_heap_block = (heap_block_header*)start;
    initial_heap_block->free = true;
    initial_heap_block->size = (size_t)(end - start);
    initial_heap_block->start_address = (uintptr_t)start;
    initial_heap_block->next = null;
    initial_heap_block->magic = HEADER_MAGIC;
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
        _put_int((long)curr->start_address);
        _put_cstring(" size: ");
        _put_int(curr->size);
        _put_cstring(curr->free ? " FREE\n\r" : " USED\n\r");
    } while (curr = curr->next);
    _put_cstring("===== HEAP END =====\n\r");
}

heap_block_header *find_next_free_block(size_t minimum_size) {
    heap_block_header *target = initial_heap_block;

    if (target == null) return null;

    do {
        if(target->free && target->size >= minimum_size) return target;
    } while(target = target->next);
    
    return null;
}

void *malloc(size_t size) {
    // we're storing the block header in the block too, so allocate for that
    size_t real_size = size + HEADER_SIZE;
    // align size to 16
    real_size = align16(real_size);

    heap_block_header *block_to_use = find_next_free_block(real_size);
    
    if (block_to_use == null) {
        _throw_error("Heap ran out of memory", "memx.c");
        return null;
    }

    if (block_to_use->magic != HEADER_MAGIC) {
        _throw_error("Block found corrupted before allocating!", "memx.c");
        return null;
    }

    // if we find an adequately sized block, we split it into two parts: one allocated, one free -
    // unless it's a perfect fit, or the new free block would be too small to store even a header
    if (block_to_use->size - real_size < HEADER_SIZE) {
        block_to_use->free = false;
        return (void *)(block_to_use->start_address + HEADER_SIZE);
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

    remaining_memory->magic = HEADER_MAGIC;

    return (void *)(allocation->start_address + HEADER_SIZE);
}

void free(void *pointer) {
    if (pointer == null) return;
    if (initial_heap_block == null) return;

    heap_block_header *target = initial_heap_block;
    heap_block_header *last_block = null;

    uintptr_t target_address = (uintptr_t)pointer - HEADER_SIZE;
    
    do {
        if (target->start_address >= target_address) {
            break;
        }
        
        last_block = target;
    } while (target = target->next);

    if (target == null || target->start_address != target_address) {
        _throw_error("Address doesn't point to start of block", "memx.c");
        return;
    }

    if (target->magic != HEADER_MAGIC) {
        _throw_error("Block found corrupted before freeing!", "memx.c");
    }

    if (target->free) {
        _throw_error("Target block was already free!", "memx.c");
        return;
    }

    target->free = true;

    // merge adjacent blocks
    if (last_block != null && last_block->free &&
        last_block->start_address + last_block->size == target->start_address) {
        last_block->size += target->size;
        last_block->next  = target->next;
        target = last_block;
    } else if (last_block == null) {
        // if nothing to merge, stretch block to heap start
        initial_heap_block = target;
    }

    // if is last block in heap, stretch to fill rest
    if (target->next == null) {
        target->size = (size_t) ((uintptr_t) &_heap_end - target->start_address);
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
void *__gnat_malloc(size_t size) {
    return malloc(size);
}

void __gnat_free(void *pointer) {
    free(pointer);
}