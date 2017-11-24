
int stindex ( char *str1, char *str2 )
{
	register int base;
	int str1ind;
	int str2ind;

	for ( base = 0; * ( str1 + base ) != '\0'; base++ ) {
		for ( str1ind = base, str2ind = 0; * ( str2 + str2ind ) != '\0' &&
		      * ( str2 + str2ind ) == * ( str1 + str1ind ); str1ind++, str2ind++ );	/* no body */

		if ( * ( str2 + str2ind ) == '\0' )
			return ( base );
	}

	return ( - 1 );	/* search failed */
}

