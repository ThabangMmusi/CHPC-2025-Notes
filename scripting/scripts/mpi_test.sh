#!/bin/bash

# Prepare a simple MPI program if it doesn't already exist
cat > mpi_hello.c <<EOL
#include <stdio.h>
#include <mpi.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    printf("Hello from rank %d\n", rank);

    MPI_Finalize();
    return 0;
}
EOL

# Compile the MPI program
mpicc mpi_hello.c -o mpi_hello

# Run the MPI program across the cluster nodes
mpirun -np 3 -host head,node1,node2 ./mpi_hello
