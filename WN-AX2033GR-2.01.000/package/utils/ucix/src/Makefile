CC?=gcc
CFLAGS?=-O2
CFLAGS+=-I./include -std=gnu99 -Wall -Werror -pedantic -fpic
LDFLAGS?=

all: libucix.so

libucix.so: ucix.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ -shared -Wl,-soname,libucix.so $^ -luci
#	$(CC) $(CFLAGS) -o ucix.o ucix.c -luci
#	$(AR) crv libucix.a ucix.o

clean:
	rm -f *.so

#UCIX_LDFLAGS:=$(LDFLAGS) -lm -luci

#CFLAGS+=-I./
#UCIX_LDFLAGS:=$(LDFLAGS) -lm -luci
#SRCS=ucix.c
#%.o: %.c ucix.h 
#	$(CC) $(CFLAGS) -Wall -c -o $@ $<
	
#OBJS = ${SRCS:.c=.o}

#all: libucix

#libucix:$(OBJS)
#	$(CC) -shared -o libucix.so $(OBJS)
#	$(AR) crv libucix.a ucix.o
	
#clean:
#	rm -f libucix.so libucix.a

