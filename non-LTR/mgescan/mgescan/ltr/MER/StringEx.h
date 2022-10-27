#ifndef __STRING_EX_H__
#define __STRING_EX_H__

#include <string>
#include <vector>

class StringEx : public std::string
{
	public:
		StringEx();
		StringEx(const std::string& s);
		StringEx(const StringEx& s);
		~StringEx();

	public:
		void clear();

		void leftTrim();
		void rightTrim();
		void trim();
		static char* leftTrim(char* s);
		static char* rightTrim(char* s);
		static char* trim(char* s);

		StringEx* split(const char* delimeter = " \t\f\r\n");
};

#include "StringEx.inl"

#endif	// __STRING_EX_H__

