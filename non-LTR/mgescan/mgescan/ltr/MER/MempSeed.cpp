#include "lib.h"
#include "MempSeed.h"
#include "RegularInterval2D.h"


MempSeed::MempSeed()
{
	m_seq    = NULL;
	m_output = NULL;
}

MempSeed::~MempSeed()
{
}

bool MempSeed::find(MultipleSequence* seq, int length, int minDist, int maxDist, IntervalSet* output)
{
	m_seq     = seq;
	m_output  = output;
	m_minDist = minDist;
	m_maxDist = maxDist;

	//NOW(stderr); 
	//fprintf(stderr, ">>>Construct generalized suffix array\n");

	m_sa.accept('A'); m_sa.accept('C'); m_sa.accept('G'); m_sa.accept('T'); 
	if ( !m_sa.sort(m_seq->at(0)->getSequence(), m_seq->at(0)->getLength())
	  || !m_sa.computeLcp() )
		return false;

	//NOW(stderr); 
	//fprintf(stderr, ">>>Compute MERs\n");

	m_sa.computeMaximalRepeat(this, length);

   return true;
}

void MempSeed::onMemp(int first1, int suffix1, int first2, int suffix2, int height)
{
	suffix1 = m_sa.realPos(suffix1);
	suffix2 = m_sa.realPos(suffix2);

	int dist = suffix2 - suffix1 - height;
	if (m_minDist <= dist && dist <= m_maxDist)
	{
		m_output->add(RegularInterval2D::newInterval(suffix1, suffix2, height));
//		printf("%d\t%d\t%d\n", suffix1, suffix2, height);
	}
}

