#ifndef __MEMP_SEED_H__
#define __MEMP_SEED_H__

#include "MempInterface.h"
#include "IntervalSet.h"
#include "MERSuffixArray.h"

class MempSeed : public MempInterface
{
	public:
		MempSeed();
		~MempSeed();

	protected:
		MERSuffixArray    m_sa;
		MultipleSequence* m_seq;
		IntervalSet*      m_output;
		int               m_minDist;
		int               m_maxDist;

	public:
		virtual bool find(MultipleSequence* seq, int length, int minDist, int maxDist, IntervalSet* output);

		virtual void onMemp(int genome1, int suffix1, int genome2, int suffix2, int height);
		virtual void onRightMemp(int genome1, int suffix1, int genome2, int suffix2, int height) {}
};

#endif	// __MEMP_SEED_H__
