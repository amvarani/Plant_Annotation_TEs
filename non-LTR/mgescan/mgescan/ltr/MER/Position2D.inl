inline Position2D::Position2D()
{
	setAt(0, 0);
	setAt(1, 0);
}
inline Position2D::Position2D(int p1, int p2)
{
	setAt(0, p1);
	setAt(1, p2);
}
inline Position2D::Position2D(Position& pos)
{
	setAt(0, pos.at(0));
	setAt(1, pos.at(1));
}

inline Position* Position2D::newPosition()
{
	return new Position2D();
}

inline int Position2D::dimension()
{
	return m_dim;
}

inline const int Position2D::operator[](int axis) const
{
	return m_points[axis];
}
inline int Position2D::at(int axis)
{
	return m_points[axis];
}
inline void Position2D::setAt(int axis, int pos)
{
	m_points[axis] = pos;
}

