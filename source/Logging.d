module ReisenLanguage.Console;

import std.stdio;

import core.sys.windows.windows;

static ConsoleClass Console;

static void InitConsole() {
    Console = new ConsoleClass();
}

enum Coloring {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
	Red = 4,
    Purple = 5,
    Gold = 6,
    Gray = 7,
    DarkGray = 8,
	LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    Magenta = 13,
    Yellow = 14,
	White = 15
}

class ConsoleClass {
    public:
        HANDLE hConsole;
        CONSOLE_SCREEN_BUFFER_INFO sbi;

        this() {
            this.hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
				
			if  (GetConsoleScreenBufferInfo(hConsole, &sbi) == 0) {
				writeln("No Terminal Detected.");
			}
        }
        
        void setColor(int f,int b) {
			SetConsoleTextAttribute(hConsole, cast(short) ((b * 16) + f));
		}
            
		void resetColor() {
			SetConsoleTextAttribute(hConsole, sbi.wAttributes);
		}
}