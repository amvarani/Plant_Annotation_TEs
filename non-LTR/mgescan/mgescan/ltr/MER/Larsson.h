#ifndef __LARSSON_H__
#define __LARSSON_H__

class Larsson
{
	public:
		Larsson();
		~Larsson();

	public:
		bool suffixSort(const char* text, int len, int* suf, int flag=2);
		// flag = 0 : alphabet 0...UCHAR_MAX without checking what appears
		// 1 : limit the alphabet to the range l...k-1 that actually appears in the input
		// 2 : transform the alphabet into 1...k-1 with no gaps and minimum k, preserving the order
};

#endif	// __LARSSON_H__
