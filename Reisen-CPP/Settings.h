#pragma once

#define __reisen__ 100000001

namespace ReisenLanguage {

	class Settings {
		public:
			bool singleFileExport;
		
			static Settings& Ref() {
				static Settings ref;
				return ref;
			}
		private:
			Settings() : singleFileExport(true) {}
		
	};

	static Settings& GlobalSettings = Settings::Ref();
}