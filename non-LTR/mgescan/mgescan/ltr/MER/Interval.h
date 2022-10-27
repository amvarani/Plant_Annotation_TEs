/**
 * <p>Title: </p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2003</p>
 * <p>Company: ALGORIgene Lab.</p>
 * @author Choi, Jeong-Hyeon
 * @version 1.0
 */

#ifndef __INTERVAL_H__
#define __INTERVAL_H__

#include <stdio.h>
#include <functional>
#include "Position.h"
#include "Reverse.h"
#include "MathEx.h"

class Interval : protected virtual Position
{
	public:
		virtual ~Interval();
		virtual Interval* newInterval() = 0;

		Position* start();
		int startAt(int axis);
		void setStart(Position& pos);
		void setStartAt(int axis, int pos);

		int rcStartAt(int axis, int len);

		virtual Position* end() = 0;
		int endAt(int axis);
		virtual void setEnd(Position& pos) = 0;
		void setEndAt(int axis, int pos);

		virtual int lengthAt(int axis) = 0;
		virtual void setLengthAt(int axis, int len) = 0;
		virtual int minLength() = 0;
		virtual int maxLength() = 0;
		virtual int gap() = 0;

		int distanceAt(Interval& r, int axis);
		Position* distance(Interval& r);

		virtual bool merge(Interval& r);
		virtual bool isRegular() = 0;
		virtual bool isRC(int axis);
		bool intersects(Interval& r);
		virtual bool intersection(Interval& a, Interval* r);
		bool contains(Position& p);
		bool contains(Interval& that);

		void print(FILE* fp=stdout);

	struct lengthOrder : public std::binary_function<Interval*, Interval*, bool>
	{
		bool operator()(Interval* x, Interval* y)
  		{
  			return x->maxLength() > y->maxLength();
  		}
  	};

	struct xOrder : public std::binary_function<Interval*, Interval*, bool>
	{
		bool operator()(Interval* x, Interval* y)
  		{
  			return x->startAt(0) < y->startAt(0);
  		}
  	};
};

#include "Interval.inl"

#endif // __INTERVAL_H__
