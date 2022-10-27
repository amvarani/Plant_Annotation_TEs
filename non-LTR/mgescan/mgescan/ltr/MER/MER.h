#ifndef __REPEAT_H__
#define __REPEAT_H__


#include <map>
#include <list>
#include <stack>
#include "SuffixArray.h"
#include "SuffixArrayPostTraverseInterface.h"
#include "MempInterface.h"


class MER : public SuffixArrayPostTraverseInterface
{
	public:
		class PositionSet : public std::map< char, std::list<int> >
		{
			public:
				PositionSet() {}
				~PositionSet() {}

			public:
				void addPosition(char left, int pos) { (*this)[left].push_back(pos); }
				void unionSet(PositionSet* ps)
				{
					for (iterator itr = ps->begin(); itr != ps->end(); itr++)
					{
						std::list<int>& list = (*this)[itr->first];
						list.splice(list.end(), itr->second);
					}                                            
				}
		};

		MER(SuffixArray* sa, MempInterface* memp=NULL, int minLen=0);
		~MER();

	protected:
		SuffixArray*					m_sa;
		std::stack<int>*				m_leftStack;
		std::stack<PositionSet*>*	m_psStack;
		MempInterface*					m_memp;
		int								m_minLen;

	public:
		void onBegin(int left, int height);
		void onEnd();
		void onPushBranch(int left, int height);
		void onPushLeaf(int left, int height);
		void onPop(int left, int right, int height);

	protected:
		void popAllLeftAndPointSet();
		virtual void CartesianProduct(int height, PositionSet* a, PositionSet* b);
		virtual void CartesianProduct(int height, char x, std::list<int>& a, char y, std::list<int>& b);
};

#endif	// __REPEAT_H__
