
#include	<math.h>

extern double	_frndint();

double
ceil(x)
double	x;
{
	double	i;

	i = _frndint(x);
	if(i < x)
		return i + 1.0;
	return i;
}
