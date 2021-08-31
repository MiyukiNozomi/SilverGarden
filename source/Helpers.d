module SilverGarden.Helpers;

import std.string;
import std.array;
import std.conv;
import std.range;
import std.algorithm;

auto subRange(R)(R s, size_t beg, size_t end) {
    return s.dropExactly(beg).take(end - beg);
}

string subString(string s, size_t beg, size_t end) {
    return s.subRange(beg, end).text;
}

void getLocation(string text,int textIndex,out int line,out int col) {
    line = 1;
    col = 0;
    for (int i = 0; i <= textIndex; i++) {
        if (text[i] == '\n') {
            ++line;
            col = 0;
        } else {
            ++col;
        }
    }
}