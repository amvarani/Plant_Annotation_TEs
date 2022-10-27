#ifndef __SUFFIXARRAY_H__
#define __SUFFIXARRAY_H__

#include <string.h>
#include "SuffixArrayPostTraverseInterface.h"
#include "MultipleSequence.h"
#include "MempInterface.h"


class SuffixArray
{
	public:
		SuffixArray(bool autoDelete=true);
		~SuffixArray();

	public:
		static const char TERMINATION;
	protected:
		bool  m_auto;
		char* m_text;		// concatenated string
		int*	m_len;		// length array of each string
		int*	m_index;		// index array to start each string
		int	m_totLen;	// total length
		int	m_count;		// the number of string
		int*	m_suffix;	// sorted suffix array
		int*	m_lcp;		// lcp array between adjacent element of m_suffix
		int*	m_rank;		// rank[suffix[i]] = i;
	
	public:
		// 'no' means string number and
		// 'suffix' means the position on concatenated string
		// 'index' means the position on text, position array, and lcp array
		// 'index' is same as 'suffix' for text
		// 'relativeSuffix' means the position on each string
		int  getIndexAt(int no);
		const char* getStringAt(int no);
		char getCharAt(int suffix);
		char getCharAt(int no, int relativeSuffix);
		int  getLengthAt(int no);
		int  getActualLengthAt(int no);
		int  getTotalLength();
		int  getCount();
		int  getSuffixAt(int index);
		int  getSuffixAt(int no, int relativeSuffix);
		int  getRankAt(int index);
		int  getLcpAt(int index);
		int* getLcps();

		int  getStringNumberAt(int index);
		int  getRelativeSuffixAt(int index, int no=-1);

	protected:
		void setIndexAt(int no, int len);
		void setStringAt(int no, const char* str);
		void setCharAt(int index, char c);
		void setLengthAt(int no, int len);
		void setActualLengthAt(int no, int len);
		void setTotalLength(int n);
		void setCount(int count);

	public:
		bool sort(int no, const char** text, int* len);
		// wrapped function of sort()
		bool sort(const char* text, int len);
		bool sort(MultipleSequence* seqs);

		bool computeRank();
		bool computeLcp();
		void postTraverse(SuffixArrayPostTraverseInterface* interface=NULL);

	protected:
		void clean();
		void computeIndexAt(int no);

	#ifdef _DEBUG
	public:
		void print(FILE* fp=stdout, int flag=1);
			// flag = 1:suffix only, 2:string, 4:lcp
		void check(FILE* fp=stdout);
		void printPostTraverse(FILE* fp=stdout);
		void printMaximalExactMatch(FILE* fp=stdout, int minLen=0);
	protected:
		int scmp3(unsigned char *p, unsigned char *q, int *l, int maxl);
	#endif
};

#include "SuffixArray.inl"

#endif	// __SUFFIXARRAY_H__
