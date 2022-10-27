#include "lib.h"
#include "MultipleSequence.h"
#include "StringEx.h"

#define H_NUMBER           "# Number :"
#define H_FILE_NAME        "# FileName :"
#define H_FILE_DELIMETER   ':'

#define MAX_BUF   2048


MultipleSequence::MultipleSequence()
{
}

MultipleSequence::~MultipleSequence()
{
}

void MultipleSequence::clearAll()
{
	if (empty()) return;

	for (MultipleSequence::iterator itr = begin(); itr != end(); itr++)
		delete *itr;

	clear();
}

void MultipleSequence::printInformation(FILE* fp) const
{
	ASSERT(fp);

	fprintf(fp, H_NUMBER " %d\n", getCount());

	for (int i = 0; i < getCount(); i++)
		fprintf(fp, H_FILE_NAME " %d : %s : %d\n", i,
		        at(i)->getFilePath(), at(i)->getIndex());
}

bool MultipleSequence::loadInformation(FILE* fp, int* no, char*** seqFileName, int** seqIndex)
{
	ASSERT(fp);

	char buf[MAX_BUF], *p, *q;
	int i;

	int hNumberLen   = strlen(H_NUMBER);
	int hFileNameLen = strlen(H_FILE_NAME);

	while (fgets(buf, MAX_BUF, fp))
	{
		// Number : 2
		if (!STRNICMP(buf, H_NUMBER, hNumberLen))
		{
			*no = atoi(buf+hNumberLen);
			*seqFileName = new char*[*no];
			*seqIndex    = new int[*no];
		}
		else if (!STRNICMP(buf, H_FILE_NAME, hFileNameLen))
		{
			p = buf+hFileNameLen;
			i = atoi(p);
			ASSERT(i < *no);
			p = strchr(p, H_FILE_DELIMETER);		// start of filename
			ASSERT(p);
			q = strchr(++p, H_FILE_DELIMETER);	// end of filename
			ASSERT(q);
			*q = '\0';  q++;							// start of index
			p = StringEx::trim(p);					// trim
			(*seqIndex)[i] = atoi(q);
			(*seqFileName)[i] = new char[strlen(p)+1];
			strcpy((*seqFileName)[i], p);
			if (i == *no-1) return true;
		}
	}

	return false;
}

MultipleSequence* MultipleSequence::translate()
{
	MultipleSequence* result = new MultipleSequence();

	for (int i = 0; i < size(); i++)
	{
		for (int j = 0; j < 3; j++)
			result->add(at(i)->translate(j));
	}

	return result;
}

