#include "lib.h"
#include "ReverseComplement.h"
#include "Sequence.h"


Sequence* ReverseComplement::rc(Sequence* seq)
{
	Sequence* result = new Sequence();

	result->m_header = "RC:";
	result->m_header += seq->m_header;
	result->m_path    = seq->m_path;
	result->m_index   = seq->m_index;

	result->m_sequence.resize(seq->getLength());
	for (int i = 0; i < seq->getLength(); i++)
		result->m_sequence[i] = Complement::com(seq->m_sequence[Reverse::toReversePosition(seq->getLength(), i)]);

	return result;
}

