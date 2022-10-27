#ifndef __INTERVAL_SET_H__
#define __INTERVAL_SET_H__

#include <vector>
#include <algorithm>
#include "Interval.h"

class IntervalSet : public std::vector<Interval*>
{
	public:
		IntervalSet(int size=0);
		~IntervalSet();

	protected:
		int m_enumIndex;

	public:
		virtual void clear();

		virtual bool add(Interval* item);
		virtual int  size() const;
		void remove(int index);

		Interval* at(int index) const;
		void      setAt(int index, Interval* item);

		virtual void         load(IntervalSet* output);
		virtual IntervalSet* load();
		virtual void         save(IntervalSet* output);

		virtual void      enumerate();
		virtual bool      hasMore() const;
		virtual Interval* next();

		template<typename _Compare> void sort(_Compare comp);
		template<typename _Compare> Interval* min(_Compare comp);
		template<typename _Compare> Interval* max(_Compare comp);
};

#include "IntervalSet.inl"

#endif	// __INTERVAL_SET_H__

