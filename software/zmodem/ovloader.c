
#include <unixio.h>
#include <stdio.h>

extern unsigned ovsize;
extern char *ovstart;

extern int ovbgn(int);

/* Overlay loader for Hi-Tech C */
int ovloader( char * ovname, int args)
{
	int fd, size = -1;
	char filename[15], *p, *index();

	strcpy(filename,ovname);		/* Copy the filename */
	strcat(filename,".ovr");		/* add the extent */

	if ((fd = open(filename, 0)) < 0)
	{
		printf("\n%s.ovr 1 load error.\n",filename);
		strcpy(filename,"c0:");		/* not there -- see if it's on A0: */
		strcat(filename, (p = index(ovname,':')) ? p+1 : ovname);
		strcat(filename,".ovr");

		fd = open(filename,0);
	}

	if ( fd >= 0 ) {
		size = read(fd,ovstart,ovsize);
		close(fd);
		if (size >= 0)
			return ovbgn(args);	/* ok, execute the overlay */
	}

	printf("\n%s.ovr 2 load error.\n",filename);
	return -1;
}
