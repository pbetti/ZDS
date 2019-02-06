
#include <stddef.h>

extern void * cpm_malloc(size_t);
extern void cpm_free(void *);



void * malloc(size_t size)
{
	return cpm_malloc( size );
}

void free(void * ptr)
{
	cpm_free( ptr );
}
