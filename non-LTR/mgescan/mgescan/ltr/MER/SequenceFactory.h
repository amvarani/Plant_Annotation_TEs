#ifndef __SEQUENCE_FACTORY_H__
#define __SEQUENCE_FACTORY_H__

#include "MultipleSequence.h"
#include "BioFile.h"

class SequenceFactory
{
	public:
		enum Type {FASTA, GBK, PTT};
		SequenceFactory();
		~SequenceFactory();

	public:
		MultipleSequence* load(char* filePaths, Type def=FASTA);
		bool save(char* filePath, MultipleSequence* seqs);
		BioFile* createInstance(const char* filePath, Type def=FASTA);
};

#endif	// __SEQUENCE_FACTORY_H__

