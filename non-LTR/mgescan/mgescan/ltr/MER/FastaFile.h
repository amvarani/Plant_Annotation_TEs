#ifndef __FASTA_FILE_H__
#define __FASTA_FILE_H__

#include "FastaLikeFile.h"

class FastaFile : public FastaLikeFile
{
	public:
		FastaFile();
		~FastaFile();

	public:
		static char DELIMETER;
		virtual bool isDelimeter(char ch);
		virtual bool isDelimeter(const char* s);
		virtual char delimeter();

	public:
		static bool isFasta(const char* filePath);
};


#endif	// __FASTA_FILE_H__
