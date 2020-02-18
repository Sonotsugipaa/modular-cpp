#include <producer.hpp>

namespace {
	int counter = 0;
}

namespace ng {
	int create_number() {
		counter = (counter / 2) + (counter + 2);
		return counter;
	}
}
