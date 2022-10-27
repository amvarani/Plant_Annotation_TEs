#ifndef __MATH_H__
#define __MATH_H__

#include <math.h>


class Math
{
	public:
		template <class TYPE> static TYPE minimum(TYPE a, TYPE b)
		{
			return (a <= b) ? a : b;
		}

		template <class TYPE> static TYPE maximum(TYPE a, TYPE b)
		{
			return (a >= b) ? a : b;
		}

		template <class TYPE> static void swapMinMax(TYPE& min, TYPE& max, TYPE a, TYPE b)
		{
			if (a <= b)
			{
				min = a; max = b;
			}
			else
			{
				min = b; max = a;
			}
		}

		template <class TYPE> static TYPE abs(TYPE a)
		{
			return (a >= 0) ? a : -a;
		}

		template <class TYPE> static double log2(TYPE d)
		{
			return log(d)/log(2);
		}
};


#endif	// __MATH_H__
