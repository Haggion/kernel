#include <stddef.h>

typedef void *backtrace_state;

backtrace_state* backtrace_create_state(const char *filename, int threaded, void(*error_callback)(void *, const char *, int), void *data)
{
	return NULL;
}

void* backtrace_alloc(backtrace_state *state, size_t size, size_t alignment)
{
	return NULL;
}

int backtrace_full(backtrace_state *state, int skip, int (*callback)(void *, int uintptr_t, const char *, int), void *data)
{
	return 0;
}
