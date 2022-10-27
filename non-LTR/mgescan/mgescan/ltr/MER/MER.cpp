#include <vector>
#include <stack>
#include "lib.h"
#include "SuffixArray.h"
#include "MER.h"


MER::MER(SuffixArray* sa, MempInterface* memp, int minLen)
	: m_sa(sa), m_memp(memp), m_minLen(minLen)
{
}

MER::~MER()
{
}

void MER::onBegin(int left, int height)
{
	m_leftStack = new std::stack<int>;
	m_psStack   = new std::stack<PositionSet*>;
}

void MER::onEnd()
{
	popAllLeftAndPointSet();

	delete m_leftStack;
	delete m_psStack;
}

void MER::onPushBranch(int left, int height)
{
}

void MER::onPushLeaf(int left, int height)
{
}

void MER::onPop(int left, int right, int height)
{
	if (left == right)	// leaf node
	{
//		printf("leaf node: %d %d\n", left, height);
		if (m_minLen > height) return;	// minimum length threshold

		m_leftStack->push(left);
		PositionSet* ps = new PositionSet;
		int suffix = m_sa->getSuffixAt(left);
		ps->addPosition(suffix?m_sa->getCharAt(0, suffix-1):'\0', suffix);
		m_psStack->push(ps);
	}
	else		// branch node
	{
//		printf("branch node: %d %d %d\n", left, right, height);
		if (m_leftStack->empty()) return;	// nothing to do

		if (m_minLen > height) 	// minimum length threshold
		{
			popAllLeftAndPointSet();
			return;
		}

		// pop the first child
		int c = m_leftStack->top(); m_leftStack->pop();
		PositionSet* first = m_psStack->top(); m_psStack->pop();

		while ( !m_leftStack->empty() && (c = m_leftStack->top()) >= left && c <= right && height > 0) //@ height condition
		{
			// pop the next child
			m_leftStack->pop();
			PositionSet* next = m_psStack->top();
			m_psStack->pop();

			// make cartesian product the first and next children
			CartesianProduct(height, first, next);

			// union the first and next children
			first->unionSet(next);
			delete next;
		}

		// push the branch node
		m_leftStack->push(left);
		m_psStack->push(first);
	}
}

void MER::CartesianProduct(int height, PositionSet* a, PositionSet* b)
{
	for (PositionSet::iterator ai = a->begin(); ai != a->end(); ai++)
	{
		for (PositionSet::iterator bi = b->begin(); bi != b->end(); bi++)
		{
			if (ai->first != bi->first)
				CartesianProduct(height, ai->first, ai->second, bi->first, bi->second);
		}
	}
}

void MER::CartesianProduct(int height, char x, std::list<int>& a, char y, std::list<int>& b)
{
	for (std::list<int>::iterator aitr = a.begin(); aitr != a.end(); aitr++)
	{
		for (std::list<int>::iterator bitr = b.begin(); bitr != b.end(); bitr++)
		{
			if (m_memp)
			{
				if (*aitr <= *bitr) m_memp->onMemp(x, *aitr, y, *bitr, height);
				else                m_memp->onMemp(y, *bitr, x, *aitr, height);
			}
		}
	}
}

void MER::popAllLeftAndPointSet()
{
	while (!m_psStack->empty())
	{
		delete m_psStack->top();
		m_psStack->pop();
	}

	while (!m_leftStack->empty())
		m_leftStack->pop();
}
