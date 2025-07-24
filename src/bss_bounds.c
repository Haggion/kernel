extern char _bss_start;
extern char _bss_end;

void *get_bss_start(void) {
    return &_bss_start;
}

void *get_bss_end(void) {
    return &_bss_end;
}