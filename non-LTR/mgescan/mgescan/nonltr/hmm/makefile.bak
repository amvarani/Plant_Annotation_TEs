CC =	gcc
CFLAGS = -O3 -Wall -lm -w
SRCS =	util_lib.c hmm_lib.c test_hmm.c
OBJS = $(SRCS:.c=.o)
MAIN = MGEScan

$(MAIN): $(OBJS) 
	$(CC) $(CFLAGS) -o $(MAIN) $(OBJS)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(RM) *.o *~ $(MAIN)

# DO NOT DELETE
