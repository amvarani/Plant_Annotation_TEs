inline int Reverse::toReversePosition(int len, int pos)
{
	return len - pos - 1;
}

inline int Reverse::toReverseStart(int len, int pos, int width)
{
	return toReversePosition(len, pos+width-1);
}

