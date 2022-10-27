/**
 * <p>Title: </p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2003</p>
 * <p>Company: ALGORIgene Lab.</p>
 * @author Choi, Jeong-Hyeon
 * @version 1.0
 */

#ifndef __POSITION_2D_H__
#define __POSITION_2D_H__

#include "Position.h"

class Position2D : public virtual Position
{
	protected:
		int m_points[2];
		static int m_dim;

	public:
		Position2D();
		Position2D(int p1, int p2);
		Position2D(Position& pos);

		virtual Position* newPosition();

		virtual int dimension();

		virtual const int operator [](int axis) const;
		virtual int at(int axis);
		virtual void setAt(int axis, int pos);
};
#include "Position2D.inl"

#endif // __POSITION_2D_H__
