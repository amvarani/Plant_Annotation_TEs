#ifndef __SUFFIX_ARRAY_POST_TRAVERSE_INTERFACE_H__
#define __SUFFIX_ARRAY_POST_TRAVERSE_INTERFACE_H__


class SuffixArrayPostTraverseInterface
{
	public:
		virtual void onBegin(int left, int height) = 0;
		virtual void onEnd() = 0;
		virtual void onPushBranch(int left, int height) = 0;
		virtual void onPushLeaf(int left, int height) = 0;
		virtual void onPop(int left, int right, int height) = 0;
};


#endif	// __SUFFIX_ARRAY_POST_TRAVERSE_INTERFACE_H__

