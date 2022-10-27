/**
 * <p>Title: </p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2003</p>
 * <p>Company: ALGORIgene Lab.</p>
 * @author Choi, Jeong-Hyeon
 * @version 1.0
 */

#ifndef __POSITION_H__
#define __POSITION_H__

#include <stdio.h>

class Position
{
	public:
		virtual Position* newPosition() = 0;

		virtual int dimension() = 0;

		virtual int at(int axis) = 0;
		virtual void setAt(int axis, int pos) = 0;
		void set(Position& that);

		float distanceAt(Position& that);
		int distanceAt(Position& that, int axis);

		Position* translate(int offset);
		Position* translate(Position& offset);

		void print(FILE* fp, const char* delimeter);
};
#include "Position.inl"

#endif // __POSITION_H__
