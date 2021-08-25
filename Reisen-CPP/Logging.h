#pragma once

#include <iostream>

namespace ReisenLanguage$Logging {
#ifdef _WIN32
#include <Windows.h>
#elif defined __linux__
//do something
#elif defined __unix__
//do something
#else
#error "Unsupported Platform!"
#endif

	enum Coloring {
		Black = 0,
        Blue = 1,
        Green = 2,
        Cyan = 3,
		Red = 4,
        Purple = 5,
        Gold = 6,
        Gray = 7,
        Dark_gray = 8,
		Light_blue = 9,
        Light_green = 10,
        Light_cyan = 11,
        Light_red = 12,
        Magenta = 13,
        Yellow = 14,
		White = 15
	};
	
	class Logging {
		public:
			static Logging& Ref() {
				static Logging a;
				return a;
			}

#ifdef _WIN32
		public:
			HANDLE hConsole;
			CONSOLE_SCREEN_BUFFER_INFO sbi;
			

			void setColor(int f,int b) {
				SetConsoleTextAttribute(hConsole, (short) ((b * 16) + f));
			}

			void resetColor() {
				SetConsoleTextAttribute(hConsole, sbi.wAttributes);
			}
		private:
			Logging() {
				this->hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
				
				if (GetConsoleScreenBufferInfo(hConsole, &sbi) == 0) {
					std::printf("No Terminal Detected.");
				}
			}
#endif
		public:
			void Info(std::string message) {
				setColor(Coloring::Blue, Coloring::Black);
				std::cout << "Info:";
				resetColor();
				std::cout << "" << message.c_str() << std::endl;
			}
	};

	static Logging& Console = Logging::Ref();
}