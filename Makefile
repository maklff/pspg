all:

# Include setting from the configure script
-include config.make

# override CFLAGS += -g -O2 -Werror-implicit-function-declaration -D_POSIX_SOURCE=1 -std=c99  -Wextra -Wduplicated-cond -Wduplicated-branches -Wlogical-op -Wrestrict -Wnull-dereference -Wjump-misses-init -Wdouble-promotion -Wshadow -pedantic -fstack-protector-all -fsanitize=address -fstack-protector -fstack-protector-strong

# LDFLAGS += -fsanitize=address

DEPS=$(wildcard *.d)
PSPG_OFILES=csv.o print.o commands.o unicode.o themes.o pspg.o config.o sort.o pgclient.o args.o infra.o \
table.o string.o export.o linebuffer.o bscommands.o readline.o inputs.o theme_loader.o

OBJS=$(PSPG_OFILES)

ifdef COMPILE_MENU
ST_MENU_OFILES=st_menu.o st_menu_styles.o menu.o
OBJS+=$(ST_MENU_OFILES)
endif

all: pspg

st_menu_styles.o: src/st_menu_styles.c config.make
	$(CC)  src/st_menu_styles.c -c $(CPPFLAGS) $(CFLAGS)

st_menu.o: src/st_menu.c config.make
	$(CC)  src/st_menu.c -c $(CPPFLAGS) $(CFLAGS)

csv.o: src/pspg.h src/unicode.h src/pretty-csv.c
	$(CC)  -c  src/pretty-csv.c -o csv.o $(CPPFLAGS) $(CFLAGS)

args.o: src/pspg.h src/args.c
	$(CC)  -c  src/args.c -o args.o $(CPPFLAGS) $(CFLAGS)

print.o: src/pspg.h src/unicode.h src/print.c
	$(CC)  -c  src/print.c -o print.o $(CPPFLAGS) $(CFLAGS)

commands.o: src/pspg.h src/commands.h src/commands.c
	$(CC)  -c src/commands.c -o commands.o $(CPPFLAGS) $(CFLAGS)

config.o: src/config.h src/config.c
	$(CC)  -c src/config.c -o config.o $(CPPFLAGS) $(CFLAGS)

unicode.o: src/unicode.h src/unicode.c
	$(CC)  -c src/unicode.c -o unicode.o $(CPPFLAGS) $(CFLAGS)

themes.o: src/themes.h src/themes.c
	$(CC)  -c src/themes.c -o themes.o $(CPPFLAGS) $(CFLAGS)

sort.o: src/pspg.h src/sort.c
	$(CC)  -c src/sort.c -o sort.o $(CPPFLAGS) $(CFLAGS)

menu.o: src/pspg.h src/st_menu.h src/commands.h src/menu.c
	$(CC)  -c src/menu.c -o menu.o $(CPPFLAGS) $(CFLAGS)

pgclient.o: src/pspg.h src/pgclient.c
	$(CC)  -c src/pgclient.c -o pgclient.o $(CPPFLAGS) $(CFLAGS) $(PG_CPPFLAGS)

infra.o: src/pspg.h src/infra.c
	$(CC)  -c src/infra.c -o infra.o $(CPPFLAGS) $(CFLAGS)

table.o: src/pspg.h src/table.c
	$(CC)  -c src/table.c -o table.o $(CPPFLAGS) $(CFLAGS)

string.o: src/pspg.h src/string.c
	$(CC)  -c src/string.c -o string.o $(CPPFLAGS) $(CFLAGS)

export.o: src/pspg.h src/export.c
	$(CC)  -c src/export.c -o export.o $(CPPFLAGS) $(CFLAGS)

linebuffer.o: src/pspg.h src/linebuffer.c
	$(CC)  -c src/linebuffer.c -o linebuffer.o $(CPPFLAGS) $(CFLAGS)

readline.o: src/pspg.h src/readline.c
	$(CC)  src/readline.c -c $(CPPFLAGS) $(CFLAGS)

inputs.o: src/pspg.h src/inputs.h src/inputs.c
	$(CC)  src/inputs.c -c $(CPPFLAGS) $(CFLAGS)

bscommands.o: src/pspg.h src/bscommands.c
	$(CC)  src/bscommands.c -c $(CPPFLAGS) $(CFLAGS)

theme_loader.o: src/pspg.h src/themes.h src/theme_loader.c
	$(CC)  src/theme_loader.c -c $(CPPFLAGS) $(CFLAGS)

pspg.o: src/commands.h src/config.h src/unicode.h src/themes.h src/inputs.h src/pspg.c
	$(CC)  -c src/pspg.c -o pspg.o $(CPPFLAGS) $(CFLAGS)

pspg:  $(PSPG_OFILES) $(ST_MENU_OFILES) config.make
	$(CC)  $(PSPG_OFILES) $(ST_MENU_OFILES) -o pspg $(LDFLAGS) $(LDLIBS) $(PG_LFLAGS) $(PG_LDFLAGS) $(PG_LIBS)

man:
	ronn --manual="pspg manual" --section=1 < README.md > pspg.1

clean:
	$(RM) $(ST_MENU_OFILES)
	$(RM) $(PSPG_OFILES)
	$(RM) $(DEPS)
	$(RM) pspg

distclean: clean
	$(RM) -r autom4te.cache
	$(RM) aclocal.m4 configure
	$(RM) config.h config.log config.make config.status config.h.in

install: all
	tools/install.sh bin pspg "$(DESTDIR)$(bindir)"

man-install:
	tools/install.sh data pspg.1 "$(mandir)/man1"

strip-install: all
	strip pspg
	tools/install.sh bin pspg "$(DESTDIR)$(bindir)"

# Pull-in dependencies generated by -MD
-include $(OBJS:.o=.d)
