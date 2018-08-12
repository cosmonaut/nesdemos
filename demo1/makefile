# Demo 1 -- static sprites

AS=ophis
ASFLAGS=-v

# ophis has a few optional outputs including list files and map files.

#ophis main.s -o demo1.nes
demo1: main.s imag.chr
	$(AS) $(ASFLAGS) main.s -o demo1.nes

clean:
	rm demo1.nes
