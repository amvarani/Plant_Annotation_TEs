#ifndef __LONG_STRING_H__
#define __LONG_STRING_H__

#include <string>

class LongString : public std::string
{
public:
	LongString(int factor=1024);
	~LongString();

protected:
	int m_factor;	// for increment of buf

public:
	int  getFactor() const;
	void setFactor(int n);

public:	// overrides
	LongString& operator+=(char ch);
	LongString& operator+=(const char* s);
	LongString& operator+=(const std::string& s);
	LongString& append(const char* s);
	LongString& append(const char* s, size_type n);
	LongString& append(const std::string& s, int i, size_type n);
	LongString& append(const std::string& s);
	LongString& append(size_type n, char c);  
};

#include "LongString.inl"

#endif	// __LONG_STRING_H__
