#ifndef __BIO_FILE_H__
#define __BIO_FILE_H__

#include "MultipleSequence.h"

class BioFile
{
	public:
		BioFile();
		~BioFile();

	protected:
		const char* m_filePath;

	public:
		const char* getFilePath() const;

	public:
		MultipleSequence* load(const char* filePath, int index=-1);
		virtual MultipleSequence* loadStream(FILE* fp, int index=-1) = 0;
		bool save(const char* filePath, MultipleSequence* seqs);
		virtual bool saveStream(FILE* fp, MultipleSequence* seqs) = 0;
};


#endif	// __BIO_FILE_H__
