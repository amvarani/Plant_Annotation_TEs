/**
 * <p>Title: </p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2003</p>
 * <p>Company: ALGORIgene Lab.</p>
 * @author Choi, Jeong-Hyeon
 * @version 1.0
 */

#ifndef __REGULAR_INTERVAL_H__
#define __REGULAR_INTERVAL_H__

#include "Interval.h"

class RegularInterval : public virtual Interval
{
	protected:
		int m_length;

	public:
		RegularInterval(int dim=2);

		virtual int lengthAt(int axis);
		virtual void setLengthAt(int axis, int len);
		virtual int maxLength();
		virtual int minLength();
		virtual int gap();

		virtual bool isRegular();
};

#include "RegularInterval.inl"

#endif // __REGULAR_INTERVAL_H__
