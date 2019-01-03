/* getline: read a line into s */

#include <stdio.h>
#include <string.h>


int getline (register char *s, int lim)
{
	char * p;
	
	p = gets(s);
	p[lim] = '\0';
	
	return strlen(p);
}


