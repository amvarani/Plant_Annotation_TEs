/* suftest.c
   Copyright N. Jesper Larsson 1999.
   
   Program to test suffix sorting function. Reads a sequence of bytes from a
   file and calls suffixsort. This is the program used in the experiments in
   "Faster Suffix Sorting" by N. Jesper Larsson (jesper@cs.lth.se) and Kunihiko
   Sadakane (sada@is.s.u-tokyo.ac.jp) to time the suffixsort function in the
   file qsufsort.c.

   This software may be used freely for any purpose. However, when distributed,
   the original source must be clearly stated, and, when the source code is
   distributed, the copyright notice must be retained and any alterations in
   the code must be clearly marked. No warranty is given regarding the quality
   of this software.
*/

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include "Larsson.h"
#include "lib.h"

#include "qsufsort.c"


Larsson::Larsson()
{
}

Larsson::~Larsson()
{
}

bool Larsson::suffixSort(const char* text, int n, int* suf, int flag)
{
   int i, *rank, *pi;
   const char *pj;
   int k, l;
   unsigned char q[UCHAR_MAX+1];

   rank = new int[n+1];
   if (! rank) {
      fprintf(stderr, "new failed\n");
      return false;
   }

	if (flag == 1)
	{
	   l = UCHAR_MAX;
		k = 1;
		for (pi = rank, pj = text; pi < rank+n; pi++, pj++)
		{
			*pi = *pj;
			if (*pi < l)  l = *pi;
			if (*pi >= k) k = *pi + 1;
		}
	}
	else
	{
		for (pi = rank, pj = text; pi < rank+n; pi++, pj++)
			*pi = *pj;

		if (flag == 0)
		{
		   l = 0;
		   k = UCHAR_MAX+1;
		}
		else	// flag == 2
		{
		   for (i = 0; i <= UCHAR_MAX; ++i)
		      q[i] = 0;
		   for (pi = rank; pi < rank+n; ++pi)
  		 	   q[*pi] = 1;
		   for (i = k = 0; i <= UCHAR_MAX; ++i)
  		 	   if (q[i])
  		    	   q[i] = k++;
		   for (pi = rank; pi < rank+n; ++pi)
  		 	   *pi = q[*pi]+1;
		   l = 1;
		   ++k;
		}
	}

   suffixsort(rank, suf, n, k, l);

	delete[] rank;
   return true;
}
