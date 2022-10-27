inline int MultipleSequence::getCount() const
{
	return size();
}

inline void MultipleSequence::add(Sequence* seq)
{
	push_back(seq);
}

inline void MultipleSequence::add(MultipleSequence* seq)
{
	insert(end(), seq->begin(), seq->end());
}

inline Sequence* MultipleSequence::remove(int index)
{
	return *erase(begin()+index);
}

inline int MultipleSequence::size() const
{
	return std::vector<Sequence*>::size();
}

inline int MultipleSequence::lengthAt(int index) const
{
	ASSERT(index >= 0 && index < size());
	return at(index)->getLength();
}

inline char MultipleSequence::charAt(int index, int pos) const
{
	ASSERT(index >= 0 && index < size());
	return at(index)->residueAt(pos);
}

inline const std::string& MultipleSequence::stringAt(int index) const
{
	ASSERT(index >= 0 && index < size());
	return at(index)->string();
}

inline std::string& MultipleSequence::stringAt(int index)
{
	ASSERT(index >= 0 && index < size());
	return at(index)->string();
}

inline std::string MultipleSequence::substringAt(int index, int pos, int len) const
{
	ASSERT(index >= 0 && index < size());
	return at(index)->subSequence(pos, len);
}

