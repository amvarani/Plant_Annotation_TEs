inline IntervalSet::IntervalSet(int size)
	: std::vector<Interval*>(size)
{
}

inline IntervalSet::~IntervalSet()
{
}

inline void IntervalSet::clear()
{
	for (int i = 0; i < std::vector<Interval*>::size(); i++)
		delete at(i);

	std::vector<Interval*>::clear();
}

inline bool IntervalSet::add(Interval* item)
{
	push_back(item);
	return false;
}

inline int IntervalSet::size() const
{
	return std::vector<Interval*>::size();
}

inline void IntervalSet::remove(int index)
{
	std::vector<Interval*>::erase(begin()+index);
}

inline IntervalSet* IntervalSet::load()
{
	return this;
}

inline void IntervalSet::load(IntervalSet* output)
{
	enumerate();

	while (hasMore())
		output->add(next());
}

inline void IntervalSet::save(IntervalSet* input)
{
	input->load(this);
}

inline void IntervalSet::enumerate()
{
	m_enumIndex = 0;
}

inline bool IntervalSet::hasMore() const
{
	return m_enumIndex < size();
}

inline Interval* IntervalSet::next()
{
	return at(m_enumIndex++);
}

inline Interval* IntervalSet::at(int index) const
{
	return std::vector<Interval*>::at(index);
}

inline void IntervalSet::setAt(int index, Interval* item)
{
	std::vector<Interval*>::at(index) = item;
}

template<typename _Compare>
void IntervalSet::sort(_Compare comp)
{
	std::sort(begin(), end(), comp);
}

template<typename _Compare>
Interval* IntervalSet::min(_Compare comp)
{
	IntervalSet::const_iterator it = std::min_element(begin(), end(), comp);
	ASSERT(it != end());
	return *it;
}

template<typename _Compare>
Interval* IntervalSet::max(_Compare comp)
{
	IntervalSet::const_iterator it = std::max_element(begin(), end(), comp);
	ASSERT(it != end());
	return *it;
}

