#include "lib.h"
#include "Interval.h"


bool Interval::contains(Position& p)
{
	for (int i = 0; i < dimension(); i++)
	{
		if (p.at(i) < startAt(i) || p.at(i) > endAt(i))
			return false;
	}

	return true;
}
bool Interval::contains(Interval& that)
{
	for (int i = 0; i < dimension(); i++)
	{
		if (this->lengthAt(i) <= 0 || that.lengthAt(i) <= 0)
			return false;

		if ( that.startAt(i) < this->startAt(i)
	     || that.startAt(i) + that.lengthAt(i) > this->startAt(i) + this->lengthAt(i) )
			return false;
	}

	return true;
}

Position* Interval::distance(Interval& r)
{
	Position* p = newPosition();

	for (int i = 0; i < dimension(); i++)
	{
		p->setAt(i, distanceAt(r, i));
	}

	return p;
}

// that must be right diagonal
// return whether start position is changed
bool Interval::merge(Interval& that)
{
	bool flag = false;

	for (int i = 0; i < dimension(); i++)
	{
		int gap = that.startAt(i) - startAt(i);
		if (isRC(i))
		{
			flag = true;
			setStartAt(i, that.startAt(i));
		}

		setLengthAt(i, gap+that.lengthAt(i));
	}

	return flag;
}

bool Interval::intersection(Interval& b, Interval* r)
{
	bool flag = true;

	for (int i = 0; i < dimension(); i++)
	{
		r->setStartAt(i, Math::maximum(startAt(i), b.startAt(i)));
		r->setEndAt  (i, Math::minimum(endAt(i),   b.endAt(i)));
		if (r->startAt(i) > r->endAt(i)) flag = false;
	}

	return flag;
}

void Interval::print(FILE* fp)
{
	fputc('{', fp);
	for (int i = 0; i < dimension(); i++)
	{
		if (i > 0) fputc('-', fp);
		fprintf(fp, "[%d,%d]", startAt(i), lengthAt(i));
	}
	fputc('}', fp);
}

