#ifndef __KASAI_H__
#define __KASAI_H__

class Kasai
{
	public:
		Kasai();
		~Kasai();

	public:
		static bool computeLcp(int n, const char* text, int* suf, int* rank, int* lcp);
};

#endif	// __KASAI_H__
