/*//
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
//*/

#include <stddef.h>
/*heap definition: bdos start - program top*/

extern char * sbrk();

#define HEAP_START _cpm_sdcc_heap
#define HEAP_END (_cpm_sdcc_heap + _cpm_sdcc_heap_size)

typedef unsigned char	uint8_t;
typedef unsigned short	uint16_t;
typedef struct header	header_t;

struct header
{
	header_t *next;
	header_t *next_free;
};


uint8_t * _cpm_sdcc_heap = 0;
uint16_t _cpm_sdcc_heap_size = 0;
header_t * _cpm_sdcc_heap_free = 0;				/* First free block, 0 if no free blocks.*/


void _init_heap()
{
	_cpm_sdcc_heap = (uint8_t *)sbrk(0);						/* program size = heap start*/
	_cpm_sdcc_heap_size = *((uint16_t *)0x0006) - (uint16_t)_cpm_sdcc_heap;		/* heap size*/
	_cpm_sdcc_heap_free = (header_t *)HEAP_START;
	_cpm_sdcc_heap_free->next = (header_t *)HEAP_END;
	_cpm_sdcc_heap_free->next_free = 0;

}


void * cpm_malloc(size_t size)
{
	header_t *h;
	header_t * *f;

	if(!_cpm_sdcc_heap_free)
		_init_heap();

	if(!size || size + offsetof(struct header, next_free) < size)
		return(0);
	size += offsetof(struct header, next_free);
	if(size < sizeof(struct header)) 			/*Requiring a minimum size makes it easier to implement free(), and avoid memory leaks.*/
		size = sizeof(struct header);

	for(h = _cpm_sdcc_heap_free, f = &_cpm_sdcc_heap_free; h; f = &(h->next_free), h = h->next_free)
	{
		size_t blocksize = (char  *)(h->next) - (char  *)h;
		if(blocksize >= size) 				/*Found free block of sufficient size.*/
		{
			if(blocksize >= size + sizeof(struct header)) /*It is worth creating a new free block*/
			{
				header_t * newheader = (header_t * const)((char *)h + size);
				newheader->next = h->next;
				newheader->next_free = h->next_free;
				*f = newheader;
				h->next = newheader;
			}
			else
				*f = h->next_free;

			return(&(h->next_free));
		}
	}

	return(0);
}




void cpm_free(void *ptr)
{
	header_t *h, *next_free, *prev_free;
	header_t * *f;

	if(!ptr)
		return;

	prev_free = 0;
	for(h = _cpm_sdcc_heap_free, f = &_cpm_sdcc_heap_free; h && (void *)h < ptr; prev_free = h, f = &(h->next_free), h = h->next_free); /* Find adjacent blocks in free list*/
	next_free = h;

	h = (void  *)((char  *)(ptr) - offsetof(struct header, next_free));

	/* Insert into free list.*/
	h->next_free = next_free;
	*f = h;

	if(next_free == h->next) 		/* Merge with next block*/
	{
		h->next_free = h->next->next_free;
		h->next = h->next->next;
	}

	if (prev_free && prev_free->next == h) /* Merge with previous block*/
	{
		prev_free->next = h->next;
		prev_free->next_free = h->next_free;
	}
}

