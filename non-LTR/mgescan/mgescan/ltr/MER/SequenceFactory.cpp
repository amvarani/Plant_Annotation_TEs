#include "lib.h"
#include "SequenceFactory.h"
#include "FastaFile.h"

SequenceFactory::SequenceFactory()
{
}

SequenceFactory::~SequenceFactory()
{
}

MultipleSequence* SequenceFactory::load(char* filePath, Type def)
{
	BioFile* file = createInstance(filePath, def);
	if (!file) return NULL;
	MultipleSequence* seq = file->load(filePath, -1);

	delete file;
	return seq;
}

bool SequenceFactory::save(char* filePath, MultipleSequence* seqs)
{
	BioFile* file;
	if (!filePath)
	{
		file = new FastaFile();
	}
	else
	{
		file = createInstance(filePath);
		if (!file) return false;
	}

	return file->save(filePath, seqs);
}

BioFile* SequenceFactory::createInstance(const char* filePath, Type def)
{
	return FastaFile::isFasta(filePath) ? new FastaFile()
		: def == FASTA ? new FastaFile()
		: def == GBK   ? NULL
		: def == PTT   ? NULL : NULL;
}

