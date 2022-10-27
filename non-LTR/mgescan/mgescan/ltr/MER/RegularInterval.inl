inline RegularInterval::RegularInterval(int dim)
{
}

inline int RegularInterval::lengthAt(int axis)
{
	return m_length;
}

inline void RegularInterval::setLengthAt(int axis, int len)
{
	m_length = len;
}

inline int RegularInterval::maxLength()
{
	return m_length;
}

inline int RegularInterval::minLength()
{
	return m_length;
}

inline int RegularInterval::gap()
{
	return 0;
}

inline bool RegularInterval::isRegular()
{
	return false;
}
