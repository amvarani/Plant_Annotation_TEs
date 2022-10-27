inline int SuffixArray::getIndexAt(int no)
{
	return m_index[no];
}

inline void SuffixArray::setIndexAt(int no, int len)
{
	m_index[no] = len;
}

inline void SuffixArray::computeIndexAt(int no)
{
//	ASSERT(no > 0);
	setIndexAt(no, getIndexAt(no-1) + getLengthAt(no-1));
}

inline char SuffixArray::getCharAt(int index)
{
	return m_text[index];
}

inline char SuffixArray::getCharAt(int no, int relativeSuffix)
{
	return getCharAt(getSuffixAt(no, relativeSuffix));
}

inline void SuffixArray::setCharAt(int index, char c)
{
	m_text[index] = c;
}

inline int SuffixArray::getSuffixAt(int index)
{
	return m_suffix[index];
}

inline int SuffixArray::getSuffixAt(int no, int relativeSuffix)
{
	return getIndexAt(no) + relativeSuffix;
}

inline int SuffixArray::getRankAt(int index)
{
	return m_rank[index];
}

inline int SuffixArray::getLcpAt(int index)
{
	return m_lcp[index];
}

inline int* SuffixArray::getLcps()
{
	return m_lcp;
}

inline int SuffixArray::getLengthAt(int no)
{
	return m_len[no];
}

inline void SuffixArray::setLengthAt(int no, int len)
{
	m_len[no] = len;
}

inline int SuffixArray::getActualLengthAt(int no)
{
	return m_len[no]-1;
}

inline void SuffixArray::setActualLengthAt(int no, int len)
{
	setLengthAt(no, len+1);
}

inline int SuffixArray::getTotalLength()
{
	return m_totLen;
}

inline void SuffixArray::setTotalLength(int n)
{
	m_totLen = n;
}

inline int SuffixArray::getCount()
{
	return m_count;
}

inline void SuffixArray::setCount(int count)
{
	m_count = count;
}

inline const char* SuffixArray::getStringAt(int no)
{
	return m_text + getIndexAt(no);
}

inline void SuffixArray::setStringAt(int no, const char* str)
{
	strcpy(m_text+getIndexAt(no), str);
	setCharAt(getIndexAt(no+1)-1, TERMINATION);
}

inline int SuffixArray::getStringNumberAt(int index)
{
	int m, a = 0, b = getCount()-1;

	while (a <= b)
	{
		m = (a+b) / 2;
		if (index < getIndexAt(m)) b = m-1;
		else a = m+1;
	}

	return b;
}

inline int SuffixArray::getRelativeSuffixAt(int index, int no)
{
	if (no == -1) getStringNumberAt(index);
	return index - getIndexAt(no);
}

