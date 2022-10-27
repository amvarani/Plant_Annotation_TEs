#ifndef __MEMP_INTERFACE_H__
#define __MEMP_INTERFACE_H__


class MempInterface
{
	public:
		virtual void onMemp(int genome1, int suffix1, int genome2, int suffix2, int height) = 0;
		virtual void onRightMemp(int genome1, int suffix1, int genome2, int suffix2, int height) = 0;
};


#endif	// __MEMP_INTERFACE_H__
