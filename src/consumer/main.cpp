#include <iostream>
#include <producer.hpp>

int main(int, char**) {
	std::cout << "Printing 5 generated numbers:\n";
	for(unsigned i=0; i<5; ++i) {
		std::cout << '\t' << ng::create_number() << '\n';
	}
	// technically unnecessary, but formally correct
	std::cout << std::flush;
	return EXIT_SUCCESS;
}
