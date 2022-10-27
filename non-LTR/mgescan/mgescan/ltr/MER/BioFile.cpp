#include "lib.h"
#include "BioFile.h"


BioFile::BioFile()
{
	m_filePath = NULL;
}

BioFile::~BioFile()
{
}

const char* BioFile::getFilePath() const
{
	return m_filePath;
}

MultipleSequence* BioFile::load(const char* filePath, int index)
{
	m_filePath = filePath;

   FILE* fp = fopen(filePath, "rt");
   if (fp == NULL)
   {
      printf("Error: Can't open file(%s)\n", filePath);
      return false;
   }

	MultipleSequence* ret = loadStream(fp, index);
	fclose(fp);

	return ret;
}

bool BioFile::save(const char* filePath, MultipleSequence* seqs)
{
	m_filePath = filePath;

   FILE* fp = filePath ? fopen(filePath, "wt") : stdout;
   if (fp == NULL)
   {
      printf("Error: Can't create file(%s)\n", filePath);
      return false;
   }

	bool ret = saveStream(fp, seqs);
	if (fp != stdout) fclose(fp);

	return ret;
}

