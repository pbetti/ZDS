
#include <unixio.h>
#include <stdio.h>

extern unsigned ovsize;
extern char *ovstart;

extern int ovbgn(int);
extern char * index();

/* Overlay loader for Hi-Tech C */
int ovloader( char * ovname, int args)
{
	int fd, size = -1;
	char filename[15], *p;

	strcpy(filename,ovname);				/* Copy the filename */
	strcat(filename,".ovr");				/* add the extent */
	
	/*printf("\nloading %s", filename);*/

	if ((fd = open(filename, 0)) < 0)
	{
		printf("\n%s open error.\n",filename);

		strcpy(filename,"C15:");			/* not there -- see if it's on C15: */
		strcat(filename, (p = index(ovname,':')) ? p+1 : ovname);
		strcat(filename,".ovr");

		fd = open(filename,0);
		/*printf("\ntrying %s", filename);*/
	}

	if ( fd >= 0 ) {
		size = read(fd,ovstart,ovsize);
		close(fd);
		if (size >= 0)
			return ovbgn(args);	/* ok, execute the overlay */
	}

	printf("\n%s load error.\n",filename);
	return -1;
}
