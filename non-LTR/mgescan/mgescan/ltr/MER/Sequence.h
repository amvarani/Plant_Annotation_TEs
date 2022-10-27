#ifndef __SEQUENCE_H__
#define __SEQUENCE_H__

#include <string.h>
#include "LongString.h"
#include "Complement.h"
#include "Reverse.h"
#include "ReverseComplement.h"
#include "Translation.h"

class Sequence
{
	public:
		Sequence();
		~Sequence();

	protected:
		std::string m_header;
		LongString  m_sequence;
		std::string m_path;
		int         m_index;

	public:
		const char* getHeader() const;
		const char* getSequence() const;
		int getLength() const;
		const char* getFilePath() const;
		int getIndex() const;

		void setHeader(const char* str);
		void setSequence(const char* str);
		void setFilePath(const char* str);
		void setIndex(int n);
		void addResidue(char ch);
		char residueAt(int pos) const;
		const std::string& string() const;
		std::string& string();
		const LongString* sequence() const;
		LongString* sequence();
		std::string  subSequence(int pos, int len);

		Sequence* complement();
		Sequence* reverseComplement();
		int toReversePosition(int pos);
		Sequence* translate(int pos, int len=-1);
	
	protected:
		Sequence* copyWithoutSequence();

	friend class Reverse;
	friend class Complement;
	friend class ReverseComplement;
};

#include "Sequence.inl"

#endif	// __SEQUENCE_H__
