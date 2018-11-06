//
//  '########'########::'######:::'##::: ##'########'########:'#######:::'#####:::
//  ..... ##: ##.... ##'##... ##:: ###:: ## ##.....:..... ##:'##.... ##:'##.. ##::
//  :::: ##:: ##:::: ## ##:::..::: ####: ## ##:::::::::: ##:: ##:::: ##'##:::: ##:
//  ::: ##::: ##:::: ##. ######::: ## ## ## ######::::: ##:::: #######: ##:::: ##:
//  :: ##:::: ##:::: ##:..... ##:: ##. #### ##...::::: ##::::'##.... ## ##:::: ##:
//  : ##::::: ##:::: ##'##::: ##:: ##:. ### ##::::::: ##::::: ##:::: ##. ##:: ##::
//   ######## ########:. ######::: ##::. ## ######## ########. #######::. #####:::
//  ........:........:::......::::..::::..:........:........::.......::::.....::::
//
//  Sysbios C interface library
//  P.Betti  <pbetti@lpconsul.eu>
//
//  Module: c_bios
//
//  HISTORY:
//  -[Date]- -[Who]------------- -[What]---------------------------------------
//  27.09.18 Piergiorgio Betti   Creation date
//

#include <stddef.h>
#include <cpm.h>

#undef	free

typedef struct header header_t;

struct header
{
	header_t *next;
	header_t *next_free;
};

extern header_t * _cpm_sdcc_heap_free;

void  * cpm_realloc(void *ptr, size_t size)
{
	void  *ret;
	header_t *h, *next_free, *prev_free;
	header_t * *f, * *pf;
	size_t blocksize, oldblocksize, maxblocksize;

	if(!_cpm_sdcc_heap_free)
		_init_heap();

	if(!ptr)
		return(malloc(size));

	if(!size)
	{
		cpm_free(ptr);
		return(0);
	}

	prev_free = 0, pf = 0;
	for(h = _cpm_sdcc_heap_free, f = &_cpm_sdcc_heap_free; h && h < ptr; prev_free = h, pf = f, f = &(h->next_free), h = h->next_free); // Find adjacent blocks in free list
	next_free = h;

	if(!size || size + offsetof(struct header, next_free) < size)
		return(0);
	blocksize = size + offsetof(struct header, next_free);
	if(blocksize < sizeof(struct header)) // Requiring a minimum size makes it easier to implement free(), and avoid memory leaks.
		blocksize = sizeof(struct header);

	h = (void  *)((char  *)(ptr) - offsetof(struct header, next_free));
	oldblocksize = (char  *)(h->next) - (char  *)h;

	maxblocksize = oldblocksize;
	if(prev_free && prev_free->next == h) // Can merge with previous block
		maxblocksize += (char  *)h - (char  *)prev_free;
	if(next_free == h->next) // Can merge with next block
		maxblocksize += (char  *)(next_free->next) - (char  *)next_free;

	if(blocksize <= maxblocksize) // Can resize in place.
	{
		if(prev_free && prev_free->next == h) // Always move into previous block to defragment
		{
			memmove(prev_free, h, blocksize <= oldblocksize ? blocksize : oldblocksize);
			h = prev_free;
			*pf = next_free;
			f = pf;
		}

		if(next_free && next_free == h->next) // Merge with following block
		{
			h->next = next_free->next;
			*f = next_free->next_free;
		}

		if(maxblocksize >= blocksize + sizeof(struct header)) // Create new block from free space
		{
			header_t *const newheader = (header_t *const)((char  *)h + blocksize);
			newheader->next = h->next;
			newheader->next_free = *f;
			*f = newheader;
			h->next = newheader;
		}

		return(&(h->next_free));
	}

	if(ret = malloc(size))
	{
		size_t oldsize = oldblocksize - offsetof(struct header, next_free);
		memcpy(ret, ptr, size <= oldsize ? size : oldsize);
		cpm_free(ptr);
		return(ret);
	}

	return(0);
}

