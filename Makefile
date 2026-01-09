CC = gcc
CFLAGS = -Wall -g $(shell pkg-config --cflags luajit)
LDFLAGS = $(shell pkg-config --libs luajit)
FLEX = flex
BISON = bison

TARGET = parser
SOURCES = lex.yy.c parser.tab.c
OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

parser.tab.c parser.tab.h: parser.y
	$(BISON) -d parser.y

lex.yy.c: lexer.l parser.tab.h
	$(FLEX) lexer.l

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(TARGET) $(OBJECTS) lex.yy.c parser.tab.c parser.tab.h

test: $(TARGET)
	./$(TARGET) test.txt

.PHONY: all clean test
