#include "math.h"
#include "errno.h"

#define P0 0.249999999999999993e+0
#define P1 0.694360001511792852e-2
#define P2 0.165203300268279130e-4
#define Q0 0.500000000000000000e+0
#define Q1 0.555538666969001188e-1
#define Q2 0.495862884905441294e-3

#define P(z) ((P2*z + P1)*z + P0)
#define Q(z) ((Q2*z + Q1)*z + Q0)

#define EPS	2.710505e-20

double
exp(x)
double x;
{
	int n;
	double xn, g, r, z;
	extern int errno;
	
	if (x > LOGHUGE) {
		errno = ERANGE;
		return HUGE;
	}
	if (x < LOGTINY) {
		errno = ERANGE;
		return 0.0;
	}
	if (fabs(x) < EPS)
		return 1.0;
	z = modf(x * 1.4426950408889634074, &xn);
	if (z >= 0.5)
		++xn;
	n = xn;
	z = modf(x, &x);	/* break x up into fraction and integer part */
	g = ((x - xn*0.693359375) + z) + xn*2.1219444005469058277e-4;
	z = g*g;
	r = P(z)*g;
	r = 0.5 + r/(Q(z)-r);
	return ldexp(r,n+1);
}
