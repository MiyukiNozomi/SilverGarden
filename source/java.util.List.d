module java.util.List;

//not that good btw, just a basic dynamic array with fancy classes.

import std.algorithm.mutation;

template List(T) {
    interface List {
        public:
            void add(T object);

            T get(int index);

            bool contains(int index);
            
            void remove(int index);
            
            ulong size();
    }
}

template ArrayList(T) {
    class ArrayList : List!T {
        private:
            T[] buffer;

        public: this() {}

        public:
            void add(T object) {
                buffer ~= object;
            }

            bool contains(int index) {
                return (index < this.size());
            }
            
            void remove(int index) {
                buffer.remove(index);
            }

            T get(int index) {
                return buffer[index];
            }

            ulong size() {
                return buffer.length;
            }
    }
}
