#ifndef __MULTIPLE_SEQUENCE_H__
#define __MULTIPLE_SEQUENCE_H__

#include <vector>
#include "Sequence.h"
#include "StringArrayInterface.h"

class MultipleSequence : public std::vector<Sequence*>, public StringArrayInterface
{
	public:
		MultipleSequence();
		~MultipleSequence();

	protected:

	public:
		int getCount() const;
		void add(Sequence* seq);
		void add(MultipleSequence* seq);
		Sequence* remove(int index);
		void clearAll();

		void printInformation(FILE* fp) const;
		static bool loadInformation(FILE* fp, int* no, char*** seqFileName, int** seqIndex);

		MultipleSequence* translate();

		//override of StringArrayInterface
		int     size() const;
		int     lengthAt(int index) const;
		char    charAt(int index, int pos) const;
		std::string& stringAt(int index);
		const std::string& stringAt(int index) const;
		std::string  substringAt(int index, int pos, int len) const;
	protected:
};

#include "MultipleSequence.inl"

#endif	// __MULTIPLE_SEQUENCE_H__
