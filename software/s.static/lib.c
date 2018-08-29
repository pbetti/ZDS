/* lib.c - library of C procedures. */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_NAME 50	     /* maximum length of program or file name */

static char prog_name[MAX_NAME+1];   /* used in error messages */

/* savename - record a program name for error messages */
#ifdef ANSI_FUNC

void 
savename (char *name)
#else

void savename(name)
char *name;
#endif
{
	if (strlen(name) <= MAX_NAME)
		strcpy(prog_name, name);
}

/* fatal - print message and die */
#ifdef ANSI_FUNC

void 
fatal (char *msg)
#else

void fatal(msg)
char *msg;
#endif
{
	if (prog_name[0] != '\0')
		fprintf(stderr, "%s: ", prog_name);
	fprintf(stderr, "%s\n", msg);
	exit(1);
}

/* fatalf - format message, print it, and die */
#ifdef ANSI_FUNC

void 
fatalf (char *msg, char *val)
#else

void fatalf(msg, val)
char *msg, *val;
#endif
{
	if (prog_name[0] != '\0')
		fprintf(stderr, "%s: ", prog_name);
	fprintf(stderr, msg, val);
	putc('\n', stderr);
	exit(1);
}
	
/* ckopen - open file; check for success */
#ifdef ANSI_FUNC

FILE *
ckopen (char *name, char *mode)
#else

FILE *ckopen(name, mode)
char *name, *mode;
#endif
{
	FILE *fp;

	if ((fp = fopen(name, mode)) == NULL)
		fatalf("Cannot open %s.", name);
	return(fp);
}

/* ckalloc - allocate space; check for success */
#ifdef ANSI_FUNC

char *
ckalloc (int amount)
#else

char *ckalloc(amount)
int amount;
#endif
{
	char *p;

	if ((p = malloc( (unsigned) amount)) == NULL)
		fatal("Ran out of memory.");
	return(p);
}

/* strsame - tell whether two strings are identical */
#ifdef ANSI_FUNC

int 
strsame (char *s, char *t)
#else

int strsame(s, t)
char *s, *t;
#endif
{
	return(strcmp(s, t) == 0);
}

/* strsave - save string s somewhere; return address */
#ifdef ANSI_FUNC

char *
strsave (char *s)
#else

char *strsave(s)
char *s;
#endif
{
	char *p;

	p = ckalloc(strlen(s)+1);	/* +1 to hold '\0' */
	return(strcpy(p, s));
}
