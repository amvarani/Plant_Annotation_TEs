#include <ctype.h>
#include "lib.h"
#include "StringEx.h"

void StringEx::leftTrim()
{
	StringEx::iterator itr;

	for (itr = begin(); itr != end(); itr++)
		if (!isspace(*itr)) break;

	erase(begin(), itr);
}

void StringEx::rightTrim()
{
	StringEx::iterator itr;

	for (itr = end(); itr != begin(); itr--)
		if (!isspace(*itr)) break;

	erase(itr+1, end());
}

void StringEx::trim()
{
	rightTrim();
	leftTrim();
}

StringEx* StringEx::split(const char* delimeter)
{
	int i = 0, j;
	std::vector<StringEx> v;

	while (i < length())
	{
		j = find(delimeter, i);
		if (j == npos) break;

		v.push_back(substr(i, j-i));
		i = j+1;
	}

	v.push_back(substr(i, j));

	StringEx* r = new StringEx[v.size()];
	for (i = 0; i < v.size(); i++)
		r[i] = v[i];

	return r;
}

char* StringEx::leftTrim(char* s)
{
	for ( ; *s; s++)
		if (!isspace(*s)) break;

	return s;
}


char* StringEx::rightTrim(char* s)
{
	char* p = s + strlen(s) - 1;

	for ( ; p >= s; p--)
		if (!isspace(*p)) break;

	p[1] = '\0';
	return p;
}

char* StringEx::trim(char* s)
{
	rightTrim(s);
	return leftTrim(s);
}

