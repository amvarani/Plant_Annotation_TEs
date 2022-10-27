#ifndef __STRING_ARRAY_INTERFACE_H__
#define __STRING_ARRAY_INTERFACE_H__

#include <string>

class StringArrayInterface
{
	public:
		virtual int size() const = 0;
		virtual int lengthAt(int index) const = 0;
		virtual char charAt(int index, int pos) const = 0;
		virtual const std::string& stringAt(int index) const = 0;
		virtual std::string& stringAt(int index) = 0;
		virtual std::string substringAt(int index, int pos, int len) const = 0;
};	// end of class StringArrayInterface

#endif	// __STRING_ARRAY_INTERFACE_H__
