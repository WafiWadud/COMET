CC = clang
CFLAGS_COMMON = -Wall -Wextra -Ithirdparty/luajit/src
CFLAGS_RELEASE = $(CFLAGS_COMMON) -O3 -march=native -flto -ffast-math -fno-ident -fno-asynchronous-unwind-tables -fno-stack-protector -funroll-loops -fomit-frame-pointer -ffunction-sections -fdata-sections -ffreestanding -fno-exceptions
CFLAGS_DEBUG = $(CFLAGS_COMMON) -O0 -g3 -ggdb3 -fno-omit-frame-pointer -fno-inline -fno-optimize-sibling-calls
CFLAGS = $(CFLAGS_RELEASE)
LDFLAGS_COMMON = -Lthirdparty/luajit/src -lluajit -lm
LDFLAGS_RELEASE = $(LDFLAGS_COMMON) -Wl,--gc-sections,--strip-all
LDFLAGS_DEBUG = $(LDFLAGS_COMMON)
LDFLAGS = $(LDFLAGS_RELEASE)
FLEX = flex
BISON = bison

LUAJIT_DIR = thirdparty/luajit
LUAJIT_LIB = $(LUAJIT_DIR)/src/libluajit.a

TARGET = parser
TARGET_DEBUG = parser-debug
SOURCES = lex.yy.c parser.tab.c
OBJECTS = $(SOURCES:.c=.o)
OBJECTS_DEBUG = $(SOURCES:.c=.debug.o)

all: release

release: CFLAGS = $(CFLAGS_RELEASE)
release: LDFLAGS = $(LDFLAGS_RELEASE)
release: $(LUAJIT_LIB) $(TARGET)

debug: CFLAGS = $(CFLAGS_DEBUG)
debug: LDFLAGS = $(LDFLAGS_DEBUG)
debug: $(LUAJIT_LIB) $(TARGET_DEBUG)

$(TARGET): $(OBJECTS) $(LUAJIT_LIB)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS) $(LDFLAGS)

$(TARGET_DEBUG): $(OBJECTS_DEBUG) $(LUAJIT_LIB)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS_DEBUG) $(LDFLAGS)

$(LUAJIT_LIB):
	$(MAKE) -C $(LUAJIT_DIR) BUILDMODE=static

parser.tab.c parser.tab.h: parser.y
	$(BISON) -d parser.y

lex.yy.c: lexer.l parser.tab.h
	$(FLEX) lexer.l

%.o: %.c
	$(CC) $(CFLAGS) -c $<

%.debug.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(TARGET) $(TARGET_DEBUG) $(OBJECTS) $(OBJECTS_DEBUG) lex.yy.c parser.tab.c parser.tab.h
	$(MAKE) -C $(LUAJIT_DIR) clean

clean-luajit:
	$(MAKE) -C $(LUAJIT_DIR) clean

test: release
	./$(TARGET) comprehensive_test.txt

test-debug: debug
	./$(TARGET_DEBUG) comprehensive_test.txt

.PHONY: all release debug clean test test-debug clean-luajit
