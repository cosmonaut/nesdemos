# demo2 makefile
#

AS=ophis
ASFLAGS=-v

# ophis has a few optional outputs including list files and map files.

demo2: main_d2.s imag.chr
	$(AS) $(ASFLAGS) main_d2.s -o demo2.nes

clean:
	rm demo2.nes
