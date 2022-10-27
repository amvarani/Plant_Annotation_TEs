#ifndef __REPEAT_SUFFIX_ARRAY_H__
#define __REPEAT__SUFFIX_ARRAYH__


#include "SuffixArray.h"
#include "MER.h"
#include <set>
#include <vector>
#include <functional>

class MERSuffixArray : public SuffixArray
{
	public:
		MERSuffixArray(int leastGap=10, bool autoDelete=true) : SuffixArray(autoDelete) { m_leastGap = leastGap; }

		void computeMaximalRepeat(MempInterface* memp=NULL, int minLen=0)
		{
			MER repeat(this, memp, minLen);
			postTraverse(&repeat);
		}

		bool sort(const char* text, int len);

		void accept(char ch)   { m_accept.insert(ch); }
		void reject(char ch)   { m_reject.insert(ch); }
		bool isAccept(char ch) { return m_accept.find(ch) != m_accept.end(); }
		bool isReject(char ch) { return m_reject.find(ch) != m_reject.end(); }
		int realPos(int pos);

	protected:
		int              m_leastGap;
		std::set<char>   m_accept;
		std::set<char>   m_reject;

		class Gap
		{
			public:
				Gap(int pos=0, int len=0, int inc=0) { m_pos = pos, m_len = len, m_inc = inc; }
			protected:
				int m_pos;
				int m_len;
				int m_inc;

			public:
				void setPos(int pos) { m_pos = pos; }
				void setEnd(int end) { m_len = end-m_pos+1; }
				void setInc(int inc) { m_inc = inc; }
				int getPos() { return m_pos; }
				int getLen() { return m_len; }
				int getInc() { return m_inc; }
		};
		std::vector<Gap> m_gaps;

		void calculateGaps();

		struct CompareGap : public std::binary_function<Gap, int, bool>
		{
			bool operator()(Gap x, int y) { return x.getPos() < y; }
		}; 
};

#endif	// __REPEAT_SUFFIX_ARRAY_H__
