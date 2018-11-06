/***************************************************************************
*   Copyright (C) 2005 by Piergiorgio Betti   *
*   pbetti@lpconsul.net   *
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
*   This program is distributed in the hope that it will be useful,       *
*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
*   GNU General Public License for more details.                          *
*                                                                         *
*   You should have received a copy of the GNU General Public License     *
*   along with this program; if not, write to the                         *
*   Free Software Foundation, Inc.,                                       *
*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
***************************************************************************/


#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <ctype.h>
#include <getopt.h>

#define VERSION	"1.0"

#define	MAXSYMBOLS	8192
#define EQUCOLS		3
#define MAXFILES	100

// typedef struct {
// 	char symbol[16];
// 	int value;
// } SYMTAB;

typedef struct hashtab_node_t {
	void *key;	/* key for the node */
	size_t keylen;	/* length of the key */
	void *value;	/* value for this node */
	size_t vallen;	/* length of the value */

	struct hashtab_node_t *next;	/* next node (open hashtable) */
} hashtab_node_t;

typedef struct hashtab_t {
	hashtab_node_t **arr;
	size_t size;	/* size of the hash */
	int count;	/* number if items in this table */
	int (*hash_func) (void *, size_t, size_t);	/* hash function */
} hashtab_t;

/* Iterator type for iterating through the hashtable. */
typedef struct hashtab_iter_t {
	/* key and value of current item */
	void *key;
	void *value;
	size_t keylen;
	size_t vallen;

	/* bookkeeping data */
	struct hashtab_internal_t {
		hashtab_t *hashtable;
		hashtab_node_t *node;
		int index;
	} internal;

} hashtab_iter_t;

static char ibuf[2048];
static char obuf[2048];
// SYMTAB symtab[MAXSYMBOLS];
char * ifiles[MAXFILES];
int verbose = 0;

void usage(void);
hashtab_t *ht_init(size_t size, int (*hash_func)
(void *key, size_t keylen, size_t ht_size));
void *ht_search(hashtab_t * hashtable, void *key, size_t keylen);
void *ht_insert(hashtab_t * hashtable, void *key, size_t keylen, void *value, size_t vallen);
void ht_remove(hashtab_t * hashtable, void *key, size_t keylen);
void *ht_grow(hashtab_t * hashtable, size_t new_size);
void ht_destroy(hashtab_t * hashtable);
void ht_iter_init(hashtab_t * hashtable, hashtab_iter_t * ii);
void ht_iter_inc(hashtab_iter_t * ii);
int ht_hash(void *key, size_t key_size, size_t hashtab_size);

#define strht_search(h, k) ht_search(h, k, strlen(k) + 1)
#define strht_insert(h, k, v) ht_insert(h, k, strlen(k) + 1, v, strlen(v) + 1)
#define strht_remove(h, k) ht_remove(h, k, strlen(k) + 1);

char * strupper(char * s)
{
	char *r = s;
	while(*s) {
		*s = toupper(*s);
		++s;
	}
	return (r);
}

int main( int argc, char *argv[] )
{
	FILE * lstf, * incf;
	int stage = 0, equn;
	char equbuf[26];
	char * equptr;
	int symcount = 0;
	int offset = 0;
	int c;
	int equcols = EQUCOLS;
	int z80asm = 0;
	int onlyentries = 0;
	int dollarpfx = 0;
	int nfile = 0, iptr;
	char * outputfilename = 0;
	char symbol[16];
	char ivalue[16];
	char svalue[16];
	int nvalue;
	char etype;

	if (argc < 3)
		usage;

	while ( ( c = getopt ( argc, argv, "o:sehO:vzd" ) ) != -1 )
		switch ( c ) {
			case 's':	/* single column equates */
				equcols = 1;
				break;

			case 'z':	/* z80asm output */
				z80asm = 1;
				break;

			case 'v':	/* verbose */
				verbose = 1;
				break;

			case 'd':	/* dollar prefixed hex */
				dollarpfx = 1;
				break;

			case 'e':	/* single column equates */
				onlyentries = 1;
				break;

			case 'o':	/* offset */
				sscanf(optarg, "%x", &offset);
				offset &= 0x0ffff;
// 				printf("Applying +%04x offset.\n", offset);
				break;

			case 'O':	/* offset */
				outputfilename = strdup(optarg);

		}

	if (!outputfilename) {
		printf("Need output file name\n");
		usage();
	}

	iptr = optind;

	while (iptr < argc) {
		ifiles[nfile] = strdup(argv[iptr]);

// 		printf("input file %s\n", ifiles[nfile]);
		if (nfile >= MAXFILES) {
			printf("Error: Too many files.\n");
			exit(1);
		}
		++nfile;
		++iptr;
	}

	if (!nfile) {
		printf("Need input file(s)\n");
		usage();
	}

	if ((incf = fopen(outputfilename, "w")) == 0)	{
		printf("Error opening %s\n", outputfilename);
		exit(1);
	}

	hashtab_t * hashtable = ht_init(MAXSYMBOLS, NULL);


	iptr = 0;

	while (iptr < nfile) {

		if ((lstf = fopen(ifiles[iptr], "r")) == 0)	{
			printf("Error opening %s\n", ifiles[iptr]);
			exit(1);
		}

		stage = 0;

		while (!feof(lstf)) {
			if (fgets(ibuf, 2048, lstf) == NULL)
				break;
				/* stage 0: search for "Symbol Table:" */
			if (stage == 0) {
				if (!strstr(ibuf, "Symbol Table:"))
					continue;
				/* got it */
				++stage;
				continue;
			}
				/* stage 1: search for next non blank/empty line */
			if (stage == 1) {
				if (!isalnum(ibuf[0]))
					continue;
				/* got it */
				++stage;
			}
				/* stage 2: process line */
			if (stage == 2) {
				/* each line is (16b sym + equal/space + 4b value + 5b filler) * equcols */
				equptr = ibuf;

				for (equn = 0; equn < equcols; equn++) {
					if ((equptr - ibuf) > strlen(ibuf) || strlen(equptr) < 20)
						break;		/* EOL */
					/* name */
					strncpy(equbuf, equptr, 25);
					equbuf[20] = '\0';

					if (symcount >= MAXSYMBOLS) {
						printf("Too many symbols !!\n");
						break;
					}

					ivalue[0] = '\0';
					sscanf(equbuf, "%s%*[ \t]%c%s", symbol, &etype, ivalue);

					if (etype == '=') {
						etype = 'q';
						strcpy(svalue, ivalue);
					}
					else if (isalnum(etype)) {
						sprintf(svalue,"%c%s", etype, ivalue);
						etype = 'e';
					}
					else {
						strcpy(svalue, ivalue);
						etype = 'x';
					}
					sscanf(svalue, "%x", &nvalue);

					equptr += 25;
					if (onlyentries && etype == 'q')
						continue;

					if (nvalue == 0)
						continue;

					if (offset) {
						nvalue = (nvalue + offset) & 0xffff;
					}

					sprintf(svalue, "%d", nvalue);

					if (!strht_search(hashtable, symbol)) {
						strht_insert( hashtable, symbol, svalue );
						++symcount;
						if (verbose)
							printf ("sym: %d - %s, value %x, type:%c inserted.\n", symcount, symbol, atoi(svalue), etype );
					}
					else if (verbose)
						printf ("sym: %s, value %x from %s, already present.\n", symbol, atoi(svalue), ifiles[iptr] );

				}
			}

		}

		fclose(lstf);
		++iptr;
	}

	/* generate output */

	fprintf(incf, ";****** Equ's file autogenerated by genequs ver: %s\n", VERSION);
	if (z80asm)
		fprintf(incf, ";z80asm (by z88dk) file format\n", VERSION);
	fprintf(incf, ";****** Input files:\n");
	iptr = 0;
	while (iptr < nfile) {
		fprintf(incf, ";****** %s\n", ifiles[iptr]);
		++iptr;
	}

	hashtab_iter_t ii;
	ht_iter_init(hashtable, &ii);
	for (; ii.key != NULL; ht_iter_inc(&ii)) {
		if (z80asm)
			fprintf(incf, "\tDEFC\t%-15s\t=\t$%04X\n", strupper((char *) ii.key), atoi((char *) ii.value));
		else if (dollarpfx)
			fprintf(incf, "%-15s\tEQU\t$%04X\n", strupper((char *) ii.key), atoi((char *) ii.value));
		else
			fprintf(incf, "%-15s\tEQU\t0%04XH\n", strupper((char *) ii.key), atoi((char *) ii.value));
	}
	fprintf(incf, ";****** EOF ***\n\n");

	return EXIT_SUCCESS;
}

void usage()
{
		printf("Usage: genequs [-o hexoffset] [-e] [-s] outputfile lstfile ...\n");
		exit(1);
}


/* Initialize a new hashtable (set bookingkeeping data) and return a
 * pointer to the hashtable. A hash function may be provided. If no
 * function pointer is given (a NULL pointer), then the built in hash
 * function is used. A NULL pointer returned if the creation of the
 * hashtable failed due to a failed malloc(). */
hashtab_t * ht_init(size_t size, int (*hash_func) (void *, size_t, size_t))
{
	hashtab_t *new_ht = (hashtab_t *) malloc(sizeof(hashtab_t));

	new_ht->arr =
	(hashtab_node_t **) malloc(sizeof(hashtab_node_t *) * size);

	new_ht->size = size;
	new_ht->count = 0;

	/* all entries are empty */
	int i = 0;
	for (i = 0; i < (int) size; i++) {
		new_ht->arr[i] = NULL;
	}

	if (hash_func == NULL)
		new_ht->hash_func = &ht_hash;
	else
		new_ht->hash_func = hash_func;

	return new_ht;
}

void *ht_search(hashtab_t * hashtable, void *key, size_t keylen)
{
	int index = ht_hash(key, keylen, hashtable->size);

	if (hashtable->arr[index] == NULL)
		return NULL;

	hashtab_node_t *last_node = hashtable->arr[index];
	while (last_node != NULL) {
		/* only compare matching keylens */
		if (last_node->keylen == keylen) {
			/* compare keys */
			if (memcmp(key, last_node->key, keylen) == 0) {
				return last_node->value;
			}
		}

		last_node = last_node->next;
	}

	return NULL;
}

void *ht_insert(hashtab_t * hashtable,
		void *key, size_t keylen, void *value, size_t vallen)
{
	int index = ht_hash(key, keylen, hashtable->size);

	hashtab_node_t *next_node, *last_node;
	next_node = hashtable->arr[index];
	last_node = NULL;

	/* Search for an existing key. */
	while (next_node != NULL) {
		/* only compare matching keylens */
		if (next_node->keylen == keylen) {
			/* compare keys */
			if (memcmp(key, next_node->key, keylen) == 0) {
				/* this key already exists, replace it */
				if (next_node->vallen != vallen) {
					/* new value is a different size */
					free(next_node->value);
					next_node->value = malloc(vallen);
					if (next_node->value == NULL)
						return NULL;
				}
				memcpy(next_node->value, value, vallen);
				next_node->vallen = vallen;
				return next_node->value;
			}
		}

		last_node = next_node;
		next_node = next_node->next;
	}

	/* create a new node */
	hashtab_node_t *new_node;
	new_node = (hashtab_node_t *) malloc(sizeof(hashtab_node_t));
	if (new_node == NULL)
		return NULL;

	/* get some memory for the new node data */
	new_node->key = malloc(keylen);
	new_node->value = malloc(vallen);
	if (new_node->key == NULL || new_node->key == NULL) {
		free(new_node->key);
		free(new_node->value);
		free(new_node);
		return NULL;
	}

	/* copy over the value and key */
	memcpy(new_node->key, key, keylen);
	memcpy(new_node->value, value, vallen);
	new_node->keylen = keylen;
	new_node->vallen = vallen;

	/* no next node */
	new_node->next = NULL;

	/* Tack the new node on the end or right on the table. */
	if (last_node != NULL)
		last_node->next = new_node;
	else
		hashtable->arr[index] = new_node;

	hashtable->count++;
	return new_node->value;
}

/* delete the given key from the hashtable */
void ht_remove(hashtab_t * hashtable, void *key, size_t keylen)
{
	hashtab_node_t *last_node, *next_node;
	int index = ht_hash(key, keylen, hashtable->size);
	next_node = hashtable->arr[index];
	last_node = NULL;

	while (next_node != NULL) {
		if (next_node->keylen == keylen) {
			/* compare keys */
			if (memcmp(key, next_node->key, keylen) == 0) {
				/* free node memory */
				free(next_node->value);
				free(next_node->key);

				/* adjust the list pointers */
				if (last_node != NULL)
					last_node->next = next_node->next;
				else
					hashtable->arr[index] = next_node->next;

				/* free the node */
				free(next_node);
				break;
			}
		}

		last_node = next_node;
		next_node = next_node->next;
	}
}

/* grow the hashtable */
void *ht_grow(hashtab_t * old_ht, size_t new_size)
{
	/* create new hashtable */
	hashtab_t *new_ht = ht_init(new_size, old_ht->hash_func);
	if (new_ht == NULL)
		return NULL;

	void *ret;	/* captures return values */

	/* Iterate through the old hashtable. */
	hashtab_iter_t ii;
	ht_iter_init(old_ht, &ii);
	for (; ii.key != NULL; ht_iter_inc(&ii)) {
		ret = ht_insert(new_ht, ii.key, ii.keylen, ii.value, ii.vallen);
		if (ret == NULL) {
			/* Insert failed. Destroy new hashtable and return. */
			ht_destroy(new_ht);
			return NULL;
		}
	}

	/* Destroy the old hashtable. */
	ht_destroy(old_ht);

	return new_ht;
}

/* free all resources used by the hashtable */
void ht_destroy(hashtab_t * hashtable)
{
	hashtab_node_t *next_node, *last_node;

	/* Free each linked list in hashtable. */
	int i;
	for (i = 0; i < (int) hashtable->size; i++) {
		next_node = hashtable->arr[i];
		while (next_node != NULL) {
			/* destroy node */
			free(next_node->key);
			free(next_node->value);
			last_node = next_node;
			next_node = next_node->next;
			free(last_node);
		}
	}

	free(hashtable->arr);
	free(hashtable);
}

/* iterator initilaize */
void ht_iter_init(hashtab_t * hashtable, hashtab_iter_t * ii)
{
	/* stick in initial bookeeping data */
	ii->internal.hashtable = hashtable;
	ii->internal.node = NULL;
	ii->internal.index = -1;

	/* have iterator point to first element */
	ht_iter_inc(ii);
}

/* iterator increment */
void ht_iter_inc(hashtab_iter_t * ii)
{
	hashtab_t *hashtable = ii->internal.hashtable;
	int index = ii->internal.index;

	/* attempt to grab the next node */
	if (ii->internal.node == NULL || ii->internal.node->next == NULL)
		index++;
	else {
		/* next node in the list */
		ii->internal.node = ii->internal.node->next;
		ii->key = ii->internal.node->key;
		ii->value = ii->internal.node->value;
		ii->keylen = ii->internal.node->keylen;
		ii->vallen = ii->internal.node->vallen;
		return;
	}

	/* find next node */
	while (hashtable->arr[index] == NULL && index < (int) hashtable->size)
		index++;

	if (index >= (int) hashtable->size) {
		/* end of hashtable */
		ii->internal.node = NULL;
		ii->internal.index = (int) hashtable->size;

		ii->key = NULL;
		ii->value = NULL;
		ii->keylen = 0;
		ii->vallen = 0;
		return;
	}

	/* point to the next item in the hashtable */
	ii->internal.node = hashtable->arr[index];
	ii->internal.index = index;
	ii->key = ii->internal.node->key;
	ii->value = ii->internal.node->value;
	ii->keylen = ii->internal.node->keylen;
	ii->vallen = ii->internal.node->vallen;
}

int ht_hash(void *key, size_t keylen, size_t hashtab_size)
{
	int sum = 0;

	/* very simple hash function for now */
	int i;
	for (i = 0; i < (int) keylen; i++) {
		sum += ((unsigned char *) key)[i] * (i + 1);
	}

	return (sum % (int) hashtab_size);
}
