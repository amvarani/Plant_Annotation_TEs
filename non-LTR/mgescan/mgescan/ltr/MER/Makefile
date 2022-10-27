APP=ltr
SOURCES= File.cpp StringEx.cpp \
        MER.cpp MERSuffixArray.cpp MempSeed.cpp SuffixArray.cpp Larsson.cpp Kasai.cpp \
        BioFile.cpp FastaFile.cpp FastaLikeFile.cpp MultipleSequence.cpp SequenceFactory.cpp \
        Reverse.cpp Complement.cpp ReverseComplement.cpp Translation.cpp \
		  Position.cpp Position2D.cpp Interval.cpp \
        ltr.cpp

OBJECTS= $(SOURCES:.cpp=.o)

CC=g++
#CFLAGS= -g
CFLAGS= -O3

DEPEND= makedepend
DEPEND_SRCS= $(SOURCES)

.PHONY : all clean

all: $(APP)

$(APP): $(OBJECTS)
	$(CC) -o $@ $(LFLAGS) $(INCLUDE) $^

%.o:%.cpp
	$(CC) -o $@ -c $(CFLAGS) $(INCLUDE) $<

clean:
	rm -rf $(OBJECTS)

depend:
	$(DEPEND) -s "# DO NOT DELETE THIS LINE"  \
	-- $(ALLDEFINES) $(CFLAGS) $(INCLUDE) -- $(SOURCES)

# DO NOT DELETE THIS LINE
