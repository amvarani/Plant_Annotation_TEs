#ifndef __LIB_H__
#define __LIB_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ASSERT() */
#ifdef _DEBUG
	#ifndef WIN32
		#include <assert.h>
		#define ASSERT(f)   assert(f)
	#else
		#ifdef _AFXDLL  
			#include <afx.h>
		#else
			#define ASSERT(f)   
		#endif
	#endif
#else
    #define ASSERT(f)  //
#endif

/* STRICMP(), STRNICMP() */
#ifdef WIN32
	#define STRICMP(s1, s2, l) stricmp(s1, s2)
	#define STRNICMP(s1, s2, l) strnicmp(s1, s2, l)
#else
	#define STRICMP(s1, s2, l) strcasecmp(s1, s2)
	#define STRNICMP(s1, s2, l) strncasecmp(s1, s2, l)
#endif

/* TRACE() */
#ifdef _DEBUG
	#define TRACE	printf
#else
	#define TRACE  //
#endif

/* OUTPUT() */
#define OUTPUT_TIME(var, due, str) \
	if ((clock()-var) / CLOCKS_PER_SEC >= (due)) \
	{ \
		fprintf(stderr, "%s", (str)); \
		fflush(stderr); \
		var = clock(); \
	}
#define OUTPUT_DATA(var, mod, str) \
	if ((var)++%(mod) == 0) \
	{ \
		fprintf(stderr, "%s", (str)); \
		fflush(stderr); \
	}

/* NOW() */
#include <time.h>
#define NOW(fp) \
	{ \
		time_t now = time(NULL); \
		fputs(ctime(&now), fp); \
	}

/* DEBUG with level */
#ifdef _DEBUG
	extern int Debug;
#endif

#endif

