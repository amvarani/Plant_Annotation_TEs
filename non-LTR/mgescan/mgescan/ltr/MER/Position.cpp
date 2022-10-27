#include "lib.h"
#include "Position.h"
#include <math.h>


void Position::set(Position& that)
{
	for (int i = 0; i < dimension(); i++)
		setAt(i, that.at(i));
}

float Position::distanceAt(Position& that)
{
	float dist = 0;

	for (int i = 0; i < dimension(); i++)
	{
		int d = distanceAt(that, i);
		dist += d * d;
	}

	return (float) sqrt(dist);
}

Position* Position::translate(int offset)
{
	Position* p = newPosition();
	for (int i = 0; i < dimension(); i++)
		p->setAt(i, at(i) + offset);
	return p;
}

Position* Position::translate(Position& offset)
{
	Position* p = newPosition();
	for (int i = 0; i < dimension(); i++)
		p->setAt(i, at(i) + offset.at(i));
	return p;
}

void Position::print(FILE* fp, const char* delimeter)
{
	for (int i = 0; i < dimension(); i++)
	{
		if (i > 0) fputs(delimeter, fp);
		fprintf(fp, "%d", at(i));
	}
}

