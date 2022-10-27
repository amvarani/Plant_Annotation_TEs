/* easel/esl_config.h.  Generated from esl_config.h.in by configure.  */
/* esl_config.h.in  [input to configure]
 * 
 * System-dependent configuration of Easel, by autoconf.
 * 
 * This file should be included in all Easel .c files before
 * anything else, because it may set #define's that control
 * behaviour of system includes and system libraries. An example
 * is large file support.
 * 
 */
#ifndef eslCONFIG_INCLUDED
#define eslCONFIG_INCLUDED

/* Version info.
 */
#define EASEL_VERSION "0.44"
#define EASEL_DATE "June 2018"
#define EASEL_COPYRIGHT "Copyright (C) 2018 Howard Hughes Medical Institute."
#define EASEL_LICENSE "Freely distributed under the BSD open source license."

/* Debugging/assertion hooks & verbosity level (0=none;3=most verbose) */
#define eslDEBUGLEVEL 0

/* Optional parallel implementation support */
#define eslENABLE_SSE 1
/* #undef eslENABLE_SSE4 */
/* #undef eslENABLE_AVX */
/* #undef eslENABLE_AVX512 */
/* #undef eslENABLE_NEON */
/* #undef eslENABLE_VMX */

/* #undef eslHAVE_NEON_AARCH64 */

#define HAVE_FLUSH_ZERO_MODE 1
/* #undef HAVE_DENORMALS_ZERO_MODE */

/* #undef HAVE_MPI */
#define HAVE_PTHREAD 1

/* Programs */
#define HAVE_GZIP 1

/* Libraries */
/* #undef HAVE_LIBGSL */

/* Headers */
#define HAVE_ENDIAN_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_STDINT_H 1
#define HAVE_UNISTD_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_STRINGS_H 1
#define HAVE_NETINET_IN_H 1

#define HAVE_SYS_PARAM_H 1
#define HAVE_SYS_SYSCTL_H 1

/* Types */
/* #undef WORDS_BIGENDIAN */
/* #undef int8_t */
/* #undef int16_t */
/* #undef int32_t */
/* #undef int64_t */
/* #undef uint8_t */
/* #undef uint16_t */
/* #undef uint32_t */
/* #undef uint64_t */
/* #undef off_t */

/* Compiler characteristics */
#define HAVE_FUNC_ATTRIBUTE_NORETURN 1
#define HAVE_FUNC_ATTRIBUTE_FORMAT 1

/* Functions */
/* #undef HAVE_ALIGNED_ALLOC */
/* #undef HAVE_ERFC */
#define HAVE_GETCWD 1
#define HAVE_GETPID 1
/* #undef HAVE__MM_MALLOC */
#define HAVE_POPEN 1
/* #undef HAVE_POSIX_MEMALIGN */
#define HAVE_STRCASECMP 1
#define HAVE_STRSEP 1
#define HAVE_SYSCONF 1
#define HAVE_SYSCTL 1
#define HAVE_TIMES 1

#define HAVE_FSEEKO 1

/* System services */
/* #undef _FILE_OFFSET_BITS */
/* #undef _LARGE_FILES */
/* #undef _LARGEFILE_SOURCE */

 
/* Function behavior */
#define eslSTOPWATCH_HIGHRES

#endif /*eslCONFIG_INCLUDED*/

