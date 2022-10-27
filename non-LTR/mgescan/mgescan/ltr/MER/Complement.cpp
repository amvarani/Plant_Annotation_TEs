#include "lib.h"
#include "Complement.h"
#include "Sequence.h"


Sequence* Complement::com(Sequence* seq)
{
	Sequence* result = new Sequence();

	result->m_header = "RC:";
	result->m_header += seq->m_header;
	result->m_path    = seq->m_path;
	result->m_index   = seq->m_index;

	result->m_sequence.resize(seq->getLength());
	for (int i = 0; i < seq->getLength(); i++)
		result->m_sequence[i] = com(seq->m_sequence[i]);

	return result;
}

char Complement::com(char base)
{
	switch (base)
	{
		case 'A': return 'T';
		case 'a': return 't';
		case 'T': return 'A';
		case 't': return 'a';
		case 'G': return 'C';
		case 'g': return 'c';
		case 'C': return 'G';
		case 'c': return 'g';
	}

	return 'N';
}

