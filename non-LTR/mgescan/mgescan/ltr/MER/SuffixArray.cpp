#include <stdio.h>
#include <vector>
#include <stack>
#include "lib.h"
#include "SuffixArray.h"
#include "Larsson.h"
#include "Kasai.h"

#ifdef _DEBUG
#include "SuffixArrayPrint.h"
#include "MempDebugPrint.h"
#endif

#ifndef MAXPRINT
#define MAXPRINT 10
#endif


#define MIN(a, b) ((a)<=(b) ? (a) : (b))

// Sanders
void suffixArray(int* s, int* SA, int n, int K);

const char SuffixArray::TERMINATION = '#'; 

SuffixArray::SuffixArray(bool autoDelete)
	: m_auto(autoDelete), m_text(NULL), m_suffix(NULL),
     m_rank(NULL), m_lcp(NULL), m_len(NULL), m_index(NULL)
{
}

SuffixArray::~SuffixArray()
{
	if (m_auto) clean();
}

void SuffixArray::clean()
{
	if (m_text  ) delete[] m_text;
	if (m_suffix) delete[] m_suffix;
	if (m_rank  ) delete[] m_rank;
	if (m_lcp   ) delete[] m_lcp;
	if (m_len   ) delete[] m_len;
	if (m_index ) delete[] m_index;
}

bool SuffixArray::sort(int n, const char** text, int* len)
{
	int i;

	setCount(n);

	m_len   = new int[n];
	m_index = new int[n+1];
	setIndexAt(0, 0);

	for (i = 0; i < n; i++)
	{
		setActualLengthAt(i, len[i]);
		computeIndexAt(i+1);
	}

	setTotalLength(getIndexAt(getCount()));
	
	m_text   = new char[getTotalLength()];
#ifdef SANDERS
	m_suffix = new int[getTotalLength()+3];	// Sanders
#else
	m_suffix = new int[getTotalLength()];
#endif

	if (m_text == NULL || m_suffix == NULL)
		return false;

	for (i = 0; i < n; i++)
		setStringAt(i, text[i]);

	setCharAt(getTotalLength()-1, '\0');
	
#ifdef SANDERS
	int* is = new int[getTotalLength()+3];
	if (is == NULL) return false;
	for (i = 0; i < getTotalLength()-1; i++)
	{
		switch (m_text[i])
		{
		case 'A': is[i] = 2; break;
		case 'C': is[i] = 3; break;
		case 'G': is[i] = 4; break;
		case 'T': is[i] = 6; break;
		case '#': is[i] = 1; break;
		default : is[i] = 5; break;
		}
	}
	is[i] = is[i+1] = is[i+2] = 0;

	//clock_t start = clock();
	suffixArray(is, m_suffix, getTotalLength(), 6);
	//printf("Time: %g\n", (float)(clock()-start)/CLOCKS_PER_SEC);
	delete[] is;
	return true;
#else
	//clock_t start = clock();
	Larsson alg;
	return alg.suffixSort(m_text, getTotalLength()-1, m_suffix);
	//alg.suffixSort(m_text, getTotalLength()-1, m_suffix);
	//printf("Time: %g\n", (float)(clock()-start)/CLOCKS_PER_SEC);
	//return true;
#endif
}

bool SuffixArray::sort(const char* text, int len)
{
	const char** t = new const char*[1]; t[0] = text;
	int*   l = new int[1];   l[0] = len;

	bool b = sort(1, t, l);

	delete[] t;
	delete[] l;

	return b;
}

bool SuffixArray::sort(MultipleSequence* seq)
{
	int no = seq->getCount();
	const char** text = new const char*[no];
	int*   len  = new int[no];

	for (int i = 0; i < no; i++)
	{
		text[i] = (char*) seq->at(i)->getSequence();
		len[i]  = seq->at(i)->getLength();
	}

	bool b = sort(no, text, len);

	delete[] text;
	delete[] len;

	return b;
}

bool SuffixArray::computeRank()
{
	if (m_rank) delete[] m_rank;

	m_rank = new int[getTotalLength()];
	if (m_rank == NULL)
		return false;

	for (int i = 0; i < getTotalLength(); i++)
		m_rank[m_suffix[i]] = i;

	return true;
}

bool SuffixArray::computeLcp()
{
	bool rankDelete, ret;

	if (m_rank == NULL)
	{
		if (!computeRank()) return false;
		rankDelete = true;
	}
	else
	{
		rankDelete = false;
	}

	if (m_lcp) delete[] m_lcp;
	m_lcp = new int[getTotalLength()];

	ret = Kasai::computeLcp(getTotalLength(), m_text, m_suffix, m_rank, m_lcp);

	if (rankDelete)
	{
		delete[] m_rank;
		m_rank = NULL;
	}

	return ret;
}

void SuffixArray::postTraverse(SuffixArrayPostTraverseInterface* interface)
{
	std::vector<int> v(2);
	std::stack< std::vector<int> > s;

	v[0] = v[1] = -1;
	s.push(v);

	if (interface) interface->onBegin(v[0], v[1]);

	int l, r, h;
	int n = getTotalLength();

	m_lcp[n-1] = -1;	// very important

	// start from index m: getCount()
	for (int k = getCount(); k <= n; k++)	/* k-th stage */
	{
		int lLca = k-1;
		int hLca = getLcpAt(k-1);
		v = s.top();
		l = v[0];
		h = v[1];
		
		while (h > hLca)
		{
			s.pop();
			r = k-1;

			/* report (l, r, h) */
//			printf("%d, %d, %d\n", l, r, h);
			if (interface) interface->onPop(l, r, h);

			lLca = l;	/* Update the left boundary */
			v = s.top();
			l = v[0];
			h = v[1];
		}

		if (h < hLca)
		{
			v[0] = lLca;
			v[1] = hLca;
			s.push(v);
			if (interface) interface->onPushBranch(v[0], v[1]);
//			printf("%d, %d\n", v[0], v[1]);
		}

		/* Set S_k = S */
		if (k < n)
		{
			v[0] = k;
			v[1] = n-getSuffixAt(k);//+1;
			s.push(v);
			if (interface) interface->onPushLeaf(v[0], v[1]);
//			printf("%d, %d\n", v[0], v[1]);
		}
	}	// end of for

	m_lcp[n-1] = 0;	// restore
	if (interface) interface->onEnd();
}


////////////////////////////////////////////////////////////////////////////////
// Only debug version

#ifdef _DEBUG

void SuffixArray::check(FILE* fp)
{
	int i, j;

   fprintf(fp, "checking...\n");
   for (i = 0; i < getTotalLength()-1; ++i)
	{
      if (scmp3((unsigned char*) m_text+getSuffixAt(i), (unsigned char*) m_text+getSuffixAt(i+1), &j,
			        MIN(getTotalLength()-getSuffixAt(i), getTotalLength()-getSuffixAt(i+1))) >= 0)
         fprintf(fp, "i %d m_suffix[i] %d m_suffix[i+1] %d\n", i, getSuffixAt(i), getSuffixAt(i+1));
   }
   fprintf(fp, "done.\n");
}

int SuffixArray::scmp3(unsigned char *p, unsigned char *q, int *l, int maxl)
{
   int i;
   i = 0;
   while (maxl>0 && *p==*q) {
      p++; q++; i++;
      maxl--;
   }
   *l = i;
   if (maxl>0) return *p-*q;
   return q-p;
}

void SuffixArray::print(FILE* fp, int flag)
{
	int i, j;
	char c;

   for (i = 0; i < getTotalLength(); ++i)
	{
		if (m_suffix && flag & 1)
		{
  	   	fprintf(fp, "%d\t", getSuffixAt(i));
		}
		if (m_lcp && flag & 4)
		{
  	   	fprintf(fp, "[%d]\t", getLcpAt(i));
		}
		if (m_suffix && flag & 2)
		{
			fputc('"', fp);
			for (j = getSuffixAt(i); j < getTotalLength()-1 && j-getSuffixAt(i) < MAXPRINT; ++j)
			{
				switch(c = getCharAt(j))
				{
				case '\n':
					fprintf(fp, "\\n");
					break;
  				case '\t':
					fprintf(fp, "\\t");
					break;
				default:
					fputc(c, fp);
				}
			}
			fputc('"', fp);
		}
		fputc('\n', fp);
   }
}

void SuffixArray::printPostTraverse(FILE* fp)
{
	SuffixArrayPrint print(fp);
	postTraverse(&print);
}

void SuffixArray::printMaximalExactMatch(FILE* fp, int minLen)
{
	MempDebugPrint memp(this, fp);
	computeMaximalExactMatch(&memp, minLen);
}

#endif
