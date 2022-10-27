#include "lib.h"
#include "MERSuffixArray.h"
#include <algorithm>


bool MERSuffixArray::sort(const char* text, int len)
{
	char* mask = new char[len+1];
	char* ptr = mask;
	bool flag = false;

	for (int i = 0; i < len; i++)
	{
		if ( (m_accept.size() > 0 &&  isAccept(text[i]))
		  || (m_reject.size() > 0 && !isReject(text[i])) )
		{
			*ptr++ = text[i];
			if (flag)
			{
				m_gaps.back().setEnd(i-1);
//				if (m_gaps.back().getLen() < m_limitGap) m_gaps.pop_back();
			}
//			if (flag) printf("%d] ", i-1);
			flag = false;
		}
		else if (flag == false)
		{
			m_gaps.push_back(Gap(i));
//			printf("[%d ", i);
			flag = true;
		}
	}

	*ptr = '\0';
//	if (flag) printf("%d] ", len-1); printf("\n");
	if (flag)
	{
		m_gaps.back().setEnd(len-1);
//		if (m_gaps.back().getLen() < m_limitGap) m_gaps.pop_back();
	}

	m_gaps.push_back(Gap(len));

	calculateGaps();

	bool ret = SuffixArray::sort(mask, ptr-mask);
	delete[] mask;
	return ret;
}

void MERSuffixArray::calculateGaps()
{
	int acu = 0;

	for (std::vector<Gap>::iterator itr = m_gaps.begin(); itr != m_gaps.end(); itr++)
	{
//		printf("CG: %d => ", itr->getPos());
		itr->setPos(itr->getPos()-acu-1);
		itr->setInc(acu);
		acu += itr->getLen();
//		printf("%d %d\n", itr->getPos(), itr->getInc());
	}
}

int MERSuffixArray::realPos(int pos)
{
//	printf("\t%d => ", pos);
	std::vector<Gap>::iterator itr = std::lower_bound(m_gaps.begin(), m_gaps.end(), pos, CompareGap());
//	printf("%d\n", pos+itr->getInc());
	return pos + itr->getInc();
}

