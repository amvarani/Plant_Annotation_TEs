#ifndef __FASTA_LIKE_FILE_H__
#define __FASTA_LIKE_FILE_H__

#include "BioFile.h"
class MultipleSequence;
class Sequence;

class FastaLikeFile : public BioFile
{
	public:
		FastaLikeFile();
		~FastaLikeFile();

	public:
		virtual MultipleSequence* loadStream(FILE* fp, int index=-1);
		virtual bool saveStream(FILE* fp, MultipleSequence* seqs);
		virtual bool loadHeader(FILE* fp, Sequence* seq);
		virtual bool loadSequence(FILE* fp, Sequence* seq);
		virtual bool saveSequence(FILE* fp, Sequence* seq);
		virtual bool isDelimeter(char ch) = 0;
		virtual bool isDelimeter(const char* s) = 0;
		virtual char delimeter() = 0;
};


#endif	// __FASTA_LIKE_FILE_H__
