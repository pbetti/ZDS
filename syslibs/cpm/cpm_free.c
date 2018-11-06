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

typedef struct header  header_t;

struct header
{
	header_t *next;
	header_t *next_free;
};

extern header_t * _cpm_sdcc_heap_free;

void cpm_free(void *ptr)
{
	header_t *h, *next_free, *prev_free;
	header_t * *f;

	if(!ptr)
		return;

	prev_free = 0;
	for(h = _cpm_sdcc_heap_free, f = &_cpm_sdcc_heap_free; h && h < ptr; prev_free = h, f = &(h->next_free), h = h->next_free); // Find adjacent blocks in free list
	next_free = h;

	h = (void  *)((char  *)(ptr) - offsetof(struct header, next_free));

	// Insert into free list.
	h->next_free = next_free;
	*f = h;

	if(next_free == h->next) // Merge with next block
	{
		h->next_free = h->next->next_free;
		h->next = h->next->next;
	}

	if (prev_free && prev_free->next == h) // Merge with previous block
	{
		prev_free->next = h->next;
		prev_free->next_free = h->next_free;
	}
}

