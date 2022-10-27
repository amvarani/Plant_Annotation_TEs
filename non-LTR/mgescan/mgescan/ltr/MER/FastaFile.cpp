#include <string.h>
#include "lib.h"
#include "File.h"
#include "FastaFile.h"

char FastaFile::DELIMETER = '>';

FastaFile::FastaFile()
{
}

FastaFile::~FastaFile()
{
}

bool FastaFile::isDelimeter(char ch)
{
	return ch == DELIMETER;
}

bool FastaFile::isDelimeter(const char* s)
{
	return isDelimeter(*s);
}

char FastaFile::delimeter()
{
	return DELIMETER;
}

bool FastaFile::isFasta(const char* filePath)
{
	const char* ext = File::getExtension(filePath);

#ifdef WIN32
	return !stricmp(ext, "fna")
		 || !stricmp(ext, "fa")
		 || !stricmp(ext, "fasta");
#else
	return !strcasecmp(ext, "fna")
		 || !strcasecmp(ext, "fa")
		 || !strcasecmp(ext, "fasta");
#endif
}

