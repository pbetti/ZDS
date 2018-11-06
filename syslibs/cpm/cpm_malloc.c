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

// heap definition: bdos start - program top

#define HEAP_START _cpm_sdcc_heap
#define HEAP_END (_cpm_sdcc_heap + _cpm_sdcc_heap_size)

typedef struct header	header_t;

struct header
{
	header_t *next;
	header_t *next_free;
};


uint8_t * _cpm_sdcc_heap = 0;
uint16_t _cpm_sdcc_heap_size = 0;
header_t * _cpm_sdcc_heap_free = 0;				// First free block, 0 if no free blocks.


void _init_heap()
{
	_cpm_sdcc_heap = (uint8_t *)heapend();						// program size = heap start
	_cpm_sdcc_heap_size = *((uint16_t *)0x0006) - (uint16_t)_cpm_sdcc_heap;	// heap size
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
	if(size < sizeof(struct header)) 			// Requiring a minimum size makes it easier to implement free(), and avoid memory leaks.
		size = sizeof(struct header);

	for(h = _cpm_sdcc_heap_free, f = &_cpm_sdcc_heap_free; h; f = &(h->next_free), h = h->next_free)
	{
		size_t blocksize = (char  *)(h->next) - (char  *)h;
		if(blocksize >= size) 				// Found free block of sufficient size.
		{
			if(blocksize >= size + sizeof(struct header)) // It is worth creating a new free block
			{
				header_t * const newheader = (header_t * const)((char *)h + size);
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

