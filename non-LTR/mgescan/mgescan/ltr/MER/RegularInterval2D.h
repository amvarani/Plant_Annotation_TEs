/**
 * <p>Title: </p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2003</p>
 * <p>Company: ALGORIgene Lab.</p>
 * @author Choi, Jeong-Hyeon
 * @version 1.0
 */

#ifndef __REGULAR_INTERVAL_2D_H__
#define __REGULAR_INTERVAL_2D_H__

#include "RegularInterval.h"
#include "Position2D.h"

class RegularInterval2D : public RegularInterval, public Position2D
{
	public:
		RegularInterval2D(int pos1=0, int pos2=0, int len=0);

		virtual Interval* newInterval();
		static Interval* newInterval(int pos1, int pos2, int len);

		virtual Position* end();
		virtual void setEnd(Position& pos);
};

#include "RegularInterval2D.inl"

#endif // __REGULAR_INTERVAL_2D_H__
