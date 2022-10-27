inline int Position::distanceAt(Position& that, int axis)
{
	return this->at(axis) - that.at(axis);
}

