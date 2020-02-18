# Build the producer module first, then build the consumer
. make-module.sh producer consumer
strip bin/*
bin/consumer

