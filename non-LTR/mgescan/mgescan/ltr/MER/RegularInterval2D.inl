inline RegularInterval2D::RegularInterval2D(int pos1, int pos2, int len)
{
	setStartAt(0, pos1); 
	setStartAt(1, pos2); 
	setLengthAt(0, len);
}

inline Interval* RegularInterval2D::newInterval()
{
	return new RegularInterval2D();
}

inline Interval* RegularInterval2D::newInterval(int pos1, int pos2, int len)
{
	return new RegularInterval2D(pos1, pos2, len);
}

inline Position* RegularInterval2D::end()
{
	return start()->translate(lengthAt(0)-1);
}

inline void RegularInterval2D::setEnd(Position& pos)
{
	return setLengthAt(0, pos.at(0)-start()->at(0)+1);
}

