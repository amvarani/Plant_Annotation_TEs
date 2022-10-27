#ifndef __TRANSLATION_H__
#define __TRANSLATION_H__

#include "LongString.h"
#include <map>

typedef std::pair<std::string, char> TransItemType;
typedef std::map<std::string, char> TransType;


class Translation
{
	public:
		static TransType m_table;

		static void translate(LongString* result, LongString* seq, int pos=0, int len=-1);
		static LongString* translate(LongString* seq, int pos=0, int len=-1);
};


#endif // __TRANSLATION_H__

