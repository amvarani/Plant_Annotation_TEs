inline LongString::LongString(int n)
{
	setFactor(n);
	reserve(n);
}

inline LongString::~LongString()
{
}

inline int LongString::getFactor() const
{
	return m_factor;
}

inline void LongString::setFactor(int n)
{
	m_factor = n;
}

inline LongString& LongString::operator+=(char ch)
{
	return append(1, ch);
}

inline LongString& LongString::operator+=(const char* s)
{
	return append(s);
}

inline LongString& LongString::operator+=(const std::string& s)
{
	return append(s);
}

inline LongString& LongString::append(const char* s)
{
	return append(s, strlen(s));
}

inline LongString& LongString::append(const char* s, size_type n)
{
	if (size()+n >= capacity())
		reserve(capacity()+(n/getFactor()+1)*getFactor());

	return (LongString&) std::string::append(s, n);
}

inline LongString& LongString::append(const std::string& s, int i, size_type n)
{
	if (size()+n-i >= capacity())
		reserve(capacity()+((n-i)/getFactor()+1)*getFactor());

	return (LongString&) std::string::append(s, i, n);
}

inline LongString& LongString::append(const std::string& s)
{
	if (size()+s.length() >= capacity())
		reserve(capacity()+(s.length()/getFactor()+1)*getFactor());

	return (LongString&) std::string::append(s);
}

inline LongString& LongString::append(size_type n, char ch)
{
	if (size()+n >= capacity())
		reserve(capacity()+(n/getFactor()+1)*getFactor());

	return (LongString&) std::string::append(n, ch);
}
