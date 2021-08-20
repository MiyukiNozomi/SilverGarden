module shinoa.lang.terminal;

import core.sys.windows.windows;

import std.stdio;

static Console console;

static void initTerminal() {
    console = new Console();
}


public struct Color {
    public:
        //normal colors
        static const int black = 0;
        static const int blue = 1;
        static const int green = 2;
        static const int cyan = 3;
        static const int red = 4;
        static const int purple = 5;
        static const int gold = 6;
        static const int gray = 7;
        static const int dark_gray = 8;
        static const int light_blue = 9;
        static const int light_green = 10;
        static const int light_cyan = 11;
        static const int light_red = 12;
        static const int magenta = 13;
        static const int yellow = 14;
        static const int white = 15;

    public:
        static const int black_background = 0;
        static const int blue_background = 1;
        static const int green_background = 2;
        static const int cyan_background = 3;
        static const int red_background = 4;
        static const int purple_background = 5;
        static const int gold_background = 6;
        static const int gray_background = 7;
        static const int dark_gray_background = 8;
        static const int light_blue_background = 9;
        static const int light_green_background = 10;
        static const int light_cyan_background = 11;
        static const int light_red_background = 12;
        static const int magenta_background = 13;
        static const int yellow_background = 14;
        static const int white_background = 15;
        
}

public class Console {
    
    private:
        HANDLE hConsole;
        CONSOLE_SCREEN_BUFFER_INFO sbi;
    
    public: this() {
        this.hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

        if (GetConsoleScreenBufferInfo(hConsole, &sbi) == 0) {
            writeln("No Terminal Detected.");
        }
    }

    public: void setColor(int f,int b) {
        SetConsoleTextAttribute(hConsole, cast(short) ((b * 16) + f));
    }

    public: void resetColor() {
        SetConsoleTextAttribute(hConsole, sbi.wAttributes);
    }
}
