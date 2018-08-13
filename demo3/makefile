# demo3 makefile
#

AS=ophis
ASFLAGS=-v

# ophis has a few optional outputs including list files and map files.

demo3: main_d3.s imag.chr nam1.nam
	$(AS) $(ASFLAGS) main_d3.s -o demo3.nes

clean:
	rm demo3.nes
