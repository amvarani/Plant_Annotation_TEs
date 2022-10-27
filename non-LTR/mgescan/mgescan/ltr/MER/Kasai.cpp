#include <stdio.h>
#include "lib.h"
#include "SuffixArray.h"
#include "Kasai.h"


Kasai::Kasai()
{
}

Kasai::~Kasai()
{
}

bool Kasai::computeLcp(int n, const char* text, int* suf, int* rank, int* lcp)
{
	ASSERT(text);
	ASSERT(suf);
	ASSERT(rank);
	ASSERT(lcp);

	int i;
	lcp[0] = 0;
	int h = 0;

	for (i = 0; i < n; i++)
	{
		if (rank[i] > 0)	// (rank[i] > 1) is wrong
		{
			int j = suf[rank[i]-1];

			// in order to simualte different character #1, #2, etc. for multiple comparison
			// text[i+h] != SuffixArray::TERMINATION
			while (text[i+h] != SuffixArray::TERMINATION && text[i+h] == text[j+h])
			{
				h++;
				ASSERT(i+h <= n && j+h <= n);
				//if (i+h > n || j+h > n) printf("<%d+%d=%d,%d+%d=%d>\n", i,h,i+h,j,h,j+h);
			}

			lcp[rank[i]-1] = h;
			if (h > 0) h--;
		}
	}

	lcp[n-1] = 0;
	return true;
}  // end of computeLcp()

