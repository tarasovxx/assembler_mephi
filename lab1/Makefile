AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = lab1.s
OBJS = $(SRCS:.s=.o)

EXE = lab1

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@
