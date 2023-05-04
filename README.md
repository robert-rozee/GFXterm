# GFXterm
GFXterm - VT100/ANSI Terminal Emulation with Graphics Support

GFXterm is a simple terminal emulator designed for use with Geoff Graham's single-chip
Micromite computers running MMbasic. As such, it provides just enough VT100/ANSI
emulation to use the Micromite's inbuilt editor with the default 80 column by 24 line screen
size.
In addition, GFXterm supports a set of graphics extensions that are suitable for drawing
simple charts, diagrams, and rolling graphs; lines and arcs can be drawn, enclosed
regions filled, and rectangular areas scrolled in any direction. Graphics are drawn on a
separate 'glass layer' overlaying the normal text screen. This layer is turned off be default,
only being turned on once a graphics command is received. The graphics layer can then
be turned off again by pressing alt-C to clear all graphics. GFXterm runs slightly faster with
graphics turned off.
Text and graphics layers operate completely independently of each other, and do not in
any way interact, with the text layer visible through 'clear' areas of the graphics layer
(wherever pixels are set to the colour: R=0, G=0, B=0).
The latest versions of GFXterm (2021) have been ported to Lazarus/FPC, and sucessfully
compiled for WINDOWS, LINUX, and RASPBIAN. With minimal changes it should also be possible
to compile for MACOS (the operating system formerly known as OS X).
