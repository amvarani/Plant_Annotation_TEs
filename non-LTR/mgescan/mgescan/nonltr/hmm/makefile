CC =	gcc
CFLAGS = -O3 -Wall -w # -g -O0 for gdb
SRCS =	util_lib.c hmm_lib.c main.c
OBJS = $(SRCS:.c=.o)
MAIN = MGEScan

$(MAIN): $(OBJS) 
	$(CC) $(CFLAGS) -o $(MAIN) $(OBJS) -lm

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(RM) *.o *~ $(MAIN)

# DO NOT DELETE
