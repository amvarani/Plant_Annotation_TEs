#include <ctype.h>
#include "lib.h"
#include "FastaLikeFile.h"


FastaLikeFile::FastaLikeFile()
{
}

FastaLikeFile::~FastaLikeFile()
{
}

// index : relative index to current file pointer
MultipleSequence* FastaLikeFile::loadStream(FILE* fp, int index)
{
	int ch;
	int count = 0;
	MultipleSequence* seq = new MultipleSequence();

	while (!feof(fp))
	{
		while ( (ch = fgetc(fp)) != EOF && !isDelimeter(ch)) ;

		if (ch == EOF) break;

		if (index==-1 || count == index)
		{
			Sequence* s = new Sequence;
			loadHeader(fp, s);
			loadSequence(fp, s);
			s->setFilePath(getFilePath());
			s->setIndex(count);
			seq->add(s);
		}
		count++;
	}

	return seq;
}

bool FastaLikeFile::loadSequence(FILE* fp, Sequence* seq)
{
	int ch;
	while ( (ch = fgetc(fp)) != EOF )
	{
		if (isDelimeter(ch)) { ungetc(ch, fp); break; }
		if (!isspace(ch)) seq->addResidue(toupper(ch));
	}

	return !ferror(fp);
}

bool FastaLikeFile::loadHeader(FILE* fp, Sequence* seq)
{
   // read the header of fasta
   char buf[1024];
	int n = sizeof(buf);

   if (!fgets(buf, n, fp))
   {
      fprintf(stderr, "Error: the file does not contain header\n");
      return false;
   }

	int len = strlen(buf);
	if (buf[len-1] == '\n')
	{
		buf[len-1] = '\0';
		seq->setHeader(buf);
	}
	else
	{
		seq->setHeader(buf);
		while (fgetc(fp) != '\n')	// remove header over threshold length
			if (feof(fp) || ferror(fp)) return false;
	}

	return true;
}

bool FastaLikeFile::saveStream(FILE* fp, MultipleSequence* seqs)
{
	int ch;
	int count = 0;

	for (int i = 0; i < seqs->size(); i++)
	{
		fprintf(fp, "%c%s\n", delimeter(), seqs->at(i)->getHeader());

		if (!saveSequence(fp, seqs->at(i))) return false;
	}

	return true;
}

bool FastaLikeFile::saveSequence(FILE* fp, Sequence* seq)
{
	int i;

	for (i = 0; i < seq->getLength(); i ++)
	{
		if (i > 0 && i % 70 == 0) fputc('\n', fp);
		fputc(seq->residueAt(i), fp);
	}
}

