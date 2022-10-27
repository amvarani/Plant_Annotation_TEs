inline Interval::~Interval()
{
}

inline Position* Interval::start()
{
	return this;
}
inline int Interval::startAt(int axis)
{
	return start()->at(axis);
}
inline void Interval::setStart(Position& pos)
{
	start()->set(pos);
}
inline void Interval::setStartAt(int axis, int pos)
{
	start()->setAt(axis, pos);
}

inline int Interval::rcStartAt(int axis, int len)
{
	return -Reverse::toReverseStart(len, startAt(axis), lengthAt(axis));
}

inline int Interval::endAt(int axis)
{
	return startAt(axis)+lengthAt(axis)-1;
}
inline void Interval::setEndAt(int axis, int pos)
{
	setLengthAt(axis, pos-startAt(axis)+1);
}

inline int Interval::distanceAt(Interval& r, int axis)
{
	return startAt(axis) - r.endAt(axis);
}

inline bool Interval::isRC(int axis)
{
	return startAt(axis) < 0;
}

inline bool Interval::intersects(Interval& that)
{
	for (int i = 0; i < dimension(); i++)
	{
		if ( Math::maximum(startAt(i), that.startAt(i))
		  >= Math::minimum(endAt(i),   that.endAt(i)))
			return false;
	}

	return true;
/*	return !((that.startAt(0) + that.lengthAt(0) <= this->startAt(0)) ||
				(that.startAt(1) + that.lengthAt(1) <= this->startAt(1)) ||
				(that.startAt(0) >= this->startAt(0) + this->lengthAt(0)) ||
				(that.startAt(1) >= this->startAt(1) + this->lengthAt(1)));
*/
}

