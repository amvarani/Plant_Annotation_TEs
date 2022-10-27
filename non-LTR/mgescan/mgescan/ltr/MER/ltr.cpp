#include "lib.h"
#include <climits>
#include "SequenceFactory.h"
#include "IntervalSet.h"
#include "MempSeed.h"


#define OPTION_INPUT				"i"
#define OPTION_OUTPUT			"o"
#define OPTION_SEED				"s"
#define DEFAULT_SEED				20
#define OPTION_MIN_DIST			"d"
#define DEFAULT_MIN_DIST		0
#define OPTION_MAX_DIST			"D"
#define DEFAULT_MAX_DIST		INT_MAX
#define OPTION_SORT				"S"
#define DEFAULT_SORT				false


// Global variable : argument
const char* Version = "0.1";
const char* URL     = "http://bio.informatics.indiana.edu/projectc/GAME/";
char* InputFileName;
char* OutputFileName;
int   MinSeed = DEFAULT_SEED;
int   MinDist = DEFAULT_MIN_DIST;
int   MaxDist = DEFAULT_MAX_DIST;
bool  SortFlag = DEFAULT_SORT;
//const char*  InputSeq[2]; // for alignment output


// Fuction prototype
void printUsage();
void processArgument(int n, char** arg);
void checkArgment();
void checkSequences(MultipleSequence* seqs);
FILE* openOutputStream(const char* fileName);
void saveFile(MultipleSequence* seqs, IntervalSet& set);
void saveHeader(FILE* out, MultipleSequence* seq);
void saveItem(FILE* out, int no, Interval* iv);


int main(int argc, char *argv[])
{
   if (argc < 2) 
	{
		printUsage();
      return 1;
   }
   
   processArgument(argc-1, argv+1);
   checkArgment();
   //NOW(stderr); 
   //fprintf(stderr, ">>>Load sequences\n");

   SequenceFactory sf;
   MultipleSequence* seqs = sf.load(InputFileName, SequenceFactory::FASTA);
   checkSequences(seqs);

   IntervalSet set;
   MempSeed seed;
   seed.find(seqs, MinSeed, MinDist, MaxDist, &set);

   if (SortFlag) set.sort(Interval::xOrder());
   saveFile(seqs, set);

   // clean
   seqs->clearAll();
   delete seqs;

   //NOW(stderr); 
   //fprintf(stderr, ">>>END\n");
   return 0;
}

void saveFile(MultipleSequence* seqs, IntervalSet& set)
{
	FILE* out = openOutputStream(OutputFileName);
	if (!out)
	{
		fprintf(stderr, "Can't create file : %s\n", OutputFileName ? OutputFileName : "stdout");
		exit(-1);
	}

	//saveHeader(out, seqs);          mina

	int i = 1;
	for (set.enumerate(); set.hasMore(); i++)
	{
		saveItem(out, i, set.next());
	}
}

void saveHeader(FILE* out, MultipleSequence* seqs)
{
  fprintf(out, "# FileName : %s\n", InputFileName ? InputFileName : "stdin");
  fprintf(out, "# Header : %s\n", seqs->at(0)->getHeader());
  fprintf(out, "# Options : ");
  fprintf(out, OPTION_SEED     "=%d,", MinSeed);
  fprintf(out, OPTION_MIN_DIST "=%d,", MinDist);
  fprintf(out, OPTION_MAX_DIST "=%d,", MaxDist);
  fprintf(out, OPTION_SORT     "=%c ", SortFlag ? 'T' : 'F');
  fprintf(out, "\n//\n");
}

void saveItem(FILE* out, int no, Interval* iv)
{
	fprintf(out, "%d\t%d\t%d\t%d\n", iv->startAt(0), iv->startAt(1), iv->lengthAt(1), iv->startAt(1)- iv->startAt(0) );
  //	fprintf(out, "%d\t%d\t%d\n", iv->startAt(0), iv->startAt(1), iv->lengthAt(1));   mina
//	fprintf(out, "%d\t%d\t%d\t%d\n", no, iv->startAt(0), iv->startAt(1), iv->lengthAt(1));
//	fprintf(out, "%d\t%d\t%d\t%d\t%d\t+\n", no, iv->startAt(0), iv->lengthAt(0), iv->startAt(1), iv->lengthAt(1));
}

void checkSequences(MultipleSequence* seqs)
{
	if (!seqs)
	{
     	fprintf(stderr, "Eror: Sequence loading\n");
      exit(-2);
	}
}

void checkArgment()
{
	if (!InputFileName)
	{
		fprintf(stderr, "Error: No input file\n");
		printUsage();
		exit(-1);
	}
}

void printUsage()
{
   fprintf(stderr,
		"LTR v%s: Genome Alignment by Match Extension\n"
		"-------------------------------------------------------------------------\n"
		"   SYNTAX: ltr options\n"
		"\t-" OPTION_INPUT        " string : input file (FASTA format)\n"
		"\t-" OPTION_OUTPUT       " string : output file name [stdout]\n"
		"\t-" OPTION_SEED         " int    : minimum length of seed [%d]\n"
		"\t-" OPTION_MIN_DIST " int    : minimum distance of seed [%d]\n"
		"\t-" OPTION_MAX_DIST " int    : maximum distance of seed [%d]\n"
		"\t-" OPTION_SORT     "        : sort the output in order of front seed\n"
		"-------------------------------------------------------------------------\n"
		"example> ltr -" OPTION_INPUT " NC_000908.fna -" OPTION_OUTPUT " NC_000908.ltr -" OPTION_SEED " 20\n\n"
		,
		Version,
		DEFAULT_SEED, DEFAULT_MIN_DIST, DEFAULT_MAX_DIST
	);
}

void processArgument(int n, char** arg)
{
	int i = 0, j, k;

	while (i < n && *arg[i] != '-') i++;

	while (i < n)
	{
		for (j = i + 1; j < n && *arg[j] != '-'; ) j++;

		if (arg[i][1] == OPTION_INPUT[0])	// string : input file (FASTA format)
		{
			if (j > i+1) InputFileName = arg[i+1];
		}
		else if (arg[i][1] == OPTION_OUTPUT[0])	// string : output file name
		{
			if (j > i+1) OutputFileName = arg[i+1];
		}
		else if (arg[i][1] == OPTION_SEED[0])	// int : threshold for minimum length of seed
		{
			if (j > i+1) MinSeed = atoi(arg[i+1]);
		}
		else if (arg[i][1] == OPTION_MIN_DIST[0])	// int : threshold for minimum distance of seed
		{
			if (j > i+1) MinDist = atoi(arg[i+1]);
		}
		else if (arg[i][1] == OPTION_MAX_DIST[0])	// int : threshold for maximum distance of seed
		{
			if (j > i+1) MaxDist = atoi(arg[i+1]);
		}
		else if (arg[i][1] == OPTION_SORT[0])	// int : flag for sorting
		{
			SortFlag = true;
		}

		i = j;
	}
}

FILE* openOutputStream(const char* fileName)
{
	if (fileName == NULL || *fileName == '\0')
		return stdout;

	FILE* os = fopen(fileName, "wt");
	return os;
}

