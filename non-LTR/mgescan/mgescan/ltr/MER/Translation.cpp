#include "lib.h"
#include "Translation.h"

#define N 64
#define UNKNOWN_CODON 'Z'

TransItemType translationArray[N] = {
	TransItemType("TTT", 'F'),
	TransItemType("TTC", 'F'),
	TransItemType("TTA", 'L'),
	TransItemType("TTG", 'L'),
	TransItemType("TCT", 'S'),
	TransItemType("TCC", 'S'),
	TransItemType("TCA", 'S'),
	TransItemType("TCG", 'S'),
	TransItemType("TAT", 'Y'),
	TransItemType("TAC", 'Y'),
	TransItemType("TAA", 'O'),
	TransItemType("TAG", 'O'),
	TransItemType("TGT", 'C'),
	TransItemType("TGC", 'C'),
	TransItemType("TGA", 'O'),
	TransItemType("TGG", 'W'),
	TransItemType("CTT", 'L'),
	TransItemType("CTC", 'L'),
	TransItemType("CTA", 'L'),
	TransItemType("CTG", 'L'),
	TransItemType("CCT", 'P'),
	TransItemType("CCC", 'P'),
	TransItemType("CCA", 'P'),
	TransItemType("CCG", 'P'),
	TransItemType("CAT", 'H'),
	TransItemType("CAC", 'H'),
	TransItemType("CAA", 'Q'),
	TransItemType("CAG", 'Q'),
	TransItemType("CGT", 'R'),
	TransItemType("CGC", 'R'),
	TransItemType("CGA", 'R'),
	TransItemType("CGG", 'R'),
	TransItemType("ATT", 'I'),
	TransItemType("ATC", 'I'),
	TransItemType("ATA", 'I'),
	TransItemType("ATG", 'M'),
	TransItemType("ACT", 'T'),
	TransItemType("ACC", 'T'),
	TransItemType("ACA", 'T'),
	TransItemType("ACG", 'T'),
	TransItemType("AAT", 'N'),
	TransItemType("AAC", 'N'),
	TransItemType("AAA", 'K'),
	TransItemType("AAG", 'K'),
	TransItemType("AGT", 'S'),
	TransItemType("AGC", 'S'),
	TransItemType("AGA", 'R'),
	TransItemType("AGG", 'R'),
	TransItemType("GTT", 'V'),
	TransItemType("GTC", 'V'),
	TransItemType("GTA", 'V'),
	TransItemType("GTG", 'V'),
	TransItemType("GCT", 'A'),
	TransItemType("GCC", 'A'),
	TransItemType("GCA", 'A'),
	TransItemType("GCG", 'A'),
	TransItemType("GAT", 'D'),
	TransItemType("GAC", 'D'),
	TransItemType("GAA", 'E'),
	TransItemType("GAG", 'E'),
	TransItemType("GGT", 'G'),
	TransItemType("GGC", 'G'),
	TransItemType("GGA", 'G'),
	TransItemType("GGG", 'G'),
};

TransType Translation::m_table(translationArray, translationArray+N);


LongString* Translation::translate(LongString* seq, int pos, int len)
{
	LongString* result = new LongString();
	translate(result, seq, pos, len);
	return result;
}

void Translation::translate(LongString* result, LongString* seq, int pos, int len)
{
	if (len == -1) len = seq->size() - pos;
	result->resize(len/3);

	for (int i = 0, j = 0; j+3 <= len; i++, j += 3)
	{
		TransType::iterator itr = m_table.find(seq->substr(j+pos, 3).c_str());
		result->at(i) = (itr == m_table.end()) ? UNKNOWN_CODON : itr->second;
	}
}

