inline StringEx::StringEx()
{
}

inline StringEx::StringEx(const std::string& s)
	: std::string(s)
{
}

inline StringEx::StringEx(const StringEx& s)
	: std::string(s)
{
}

inline StringEx::~StringEx()
{
}

inline void StringEx::clear()
{
	erase(begin(), end());
}

