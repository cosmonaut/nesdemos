# NESDEMO

A series of basic example programs for the Nintendo Entertainment
System (NES).

## Info

These demos are written with increasing complexity to try out
different aspects of NES programming in small segments. Short
descriptions are:

* demo1: Draw multiple sprites on the screen
* demo2: Use controller input to move a sprite and change colors
* demo3: Addition of a background
* demo4: TBD

They are loosely based on the Nerdy Nights Out demos
(http://nintendoage.com/pub/faq/NA/index.html?load=nerdy_nights_out.html). This
specific set of programs is written for use with the Ophis assembler
(http://michaelcmartin.github.io/Ophis/). 


More info on NES development can be found at http://nesdev.com/


## Requirements

The Ophis assembler is required to build these examples. With some
edits these examples could be modified to be built with ca65
(https://www.cc65.org/) or nesasm (http://www.nespowerpak.com/nesasm/
or https://github.com/toastynerd/nesasm). Makefiles are provided for
each demo but they can easily be built without use of the
makefile. Any NES emulator (e.g. fceux, nestopia, mednafen, etc.) can
be used to run the .nes output files. Mednafen
(https://mednafen.github.io/) and fceux
(http://www.fceux.com/web/home.html) are particularly useful as they
have debuggers (although the fceux debugger is Windows-only).

## Oher Useful Stuff

* easy6502 (https://skilldrick.github.io/easy6502/)
* YYCHR (https://wiki.nesdev.com/w/index.php/YY-CHR)
* NES Screen Tool (http://shiru.untergrund.net/software.shtml)
