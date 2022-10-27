#include "lib.h"
#include "Reverse.h"
#include "Sequence.h"


Sequence* Reverse::rev(Sequence* seq)
{
	Sequence* result = new Sequence();

	result->m_header = "R:";
	result->m_header += seq->m_header;
	result->m_path    = seq->m_path;
	result->m_index   = seq->m_index;

	result->m_sequence.resize(seq->getLength());
	for (int i = 0; i < seq->getLength(); i++)
		result->m_sequence[i] = seq->m_sequence[toReversePosition(seq->getLength(), i)];

	return result;
}

