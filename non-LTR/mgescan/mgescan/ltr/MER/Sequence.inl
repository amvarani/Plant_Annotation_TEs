inline Sequence::Sequence()
	: m_sequence(1024*1024)
{
}

inline Sequence::~Sequence()
{
}

inline const char* Sequence::getHeader() const
{
	return m_header.c_str();
}

inline void Sequence::setHeader(const char* s)
{
	m_header = s;
}

inline const char* Sequence::getSequence() const
{
	return m_sequence.c_str();
}

inline void Sequence::setSequence(const char* s)
{
	m_sequence.assign(s);
}

inline void Sequence::addResidue(char ch)
{
	m_sequence += ch;
}

inline int Sequence::getLength() const
{
	return m_sequence.length();
}

inline const char* Sequence::getFilePath() const
{
	return m_path.c_str();
}

inline void Sequence::setFilePath(const char* s)
{
	m_path = s;
}

inline int Sequence::getIndex() const
{
	return m_index;
}

inline void Sequence::setIndex(int n)
{
	m_index = n;
}

inline char Sequence::residueAt(int pos) const
{
	return m_sequence[pos];
}

inline const std::string& Sequence::string() const
{
	return m_sequence;
}

inline std::string& Sequence::string()
{
	return m_sequence;
}

inline const LongString* Sequence::sequence() const
{
	return &m_sequence;
}

inline LongString* Sequence::sequence()
{
	return &m_sequence;
}

inline std::string Sequence::subSequence(int pos, int len)
{
	return m_sequence.substr(pos, len);
}

inline Sequence* Sequence::complement()
{
	return Complement::com(this);
}

inline Sequence* Sequence::reverseComplement()
{
	return ReverseComplement::rc(this);
}

inline int Sequence::toReversePosition(int pos)
{
	return Reverse::toReversePosition(getLength(), pos);
}

inline Sequence* Sequence::copyWithoutSequence()
{
	Sequence* result = new Sequence();

	result->m_header = m_header;
	result->m_path  = m_path;
	result->m_index = m_index;

	return result;
}

inline Sequence* Sequence::translate(int pos, int len)
{
	Sequence* result = copyWithoutSequence();
	std::string s("T");
	s += pos;
	s += ':';
	result->m_header.insert(0, s);
	Translation::translate(result->sequence(), sequence(), pos, len);
	return result;
}

