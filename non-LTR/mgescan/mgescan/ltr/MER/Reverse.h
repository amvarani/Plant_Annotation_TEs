#ifndef __REVERSE_H__
#define __REVERSE_H__

class Sequence;

class Reverse
{
	public:
		static Sequence* rev(Sequence* seq);
		static int toReversePosition(int len, int pos);
		static int toReverseStart(int len, int pos, int width);
};

#include "Reverse.inl"

#endif // __REVERSE_H__

