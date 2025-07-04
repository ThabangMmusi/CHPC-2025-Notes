#!/bin/bash

# Ensure the TEAM_NAME variable is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a TEAM_NAME as a command-line argument."
  echo "Usage: ./tut3hpl.sh <TEAM_NAME>"
  exit 1
fi

TEAM_NAME="$1"  # Get the TEAM_NAME from the first argument

# Navigate to the home directory
echo "Navigating to the home directory..."
cd ~

# Export the path to the OpenMPI Library
echo "Exporting the OpenMPI binary path..."
export PATH=/usr/lib64/openmpi/bin:$PATH

# Navigate to the HPL bin directory for the specified team
HPL_BIN_DIR=~/hpl/bin/$TEAM_NAME
if [ ! -d "$HPL_BIN_DIR" ]; then
  echo "Error: Directory $HPL_BIN_DIR does not exist. Ensure the HPL binary for $TEAM_NAME is built."
  exit 1
fi

cd $HPL_BIN_DIR

# Prompt user to edit HPL.dat
echo "Editing HPL.dat file for team: $TEAM_NAME"
nano HPL.dat

echo "Make the following changes to your HPL.dat file:"
echo "22000                    Ns"
echo "164                      NBs"

# Run the HPL binary
echo "Running the HPL benchmark..."
./xhpl

echo "Benchmark complete.But it will complete with error!!!!"
echo "Please check the GFLOPS score displayed in the output."

# Fetch the source files from the GitHub repository
echo "Fetching and building OpenBLAS..."
cd ~
git clone https://github.com/xianyi/OpenBLAS.git
cd OpenBLAS

# Checkout specific OpenBLAS version
git checkout v0.3.26

# Build and install OpenBLAS
echo "Building OpenBLAS..."
make -j$(nproc)
echo "Installing OpenBLAS..."
make PREFIX=$HOME/opt/openblas install

# Fetch and unpack the OpenMPI source files
echo "Fetching and building OpenMPI..."
cd ~
wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.4.tar.gz
tar xf openmpi-4.1.4.tar.gz
cd openmpi-4.1.4

# Configure OpenMPI with tuning options
echo "Configuring OpenMPI..."
CFLAGS="-Ofast -march=cascadelake -mtune=cascadelake" ./configure --prefix=$HOME/opt/openmpi

# Build and install OpenMPI
echo "Building OpenMPI..."
make -j$(nproc)
echo "Installing OpenMPI..."
make install

# Prepare the Makefile for OpenBLAS and OpenMPI
echo "Copying and editing Makefile for OpenBLAS and OpenMPI..."
cd ~/hpl
cp Make.$TEAM_NAME Make.compile_BLAS_MPI
nano Make.compile_BLAS_MPI

# Export environment variables for OpenMPI
echo "Exporting environment variables for OpenMPI..."
export MPI_HOME=$HOME/opt/openmpi
export PATH=$MPI_HOME/bin:$PATH
export LD_LIBRARY_PATH=$MPI_HOME/lib:$LD_LIBRARY_PATH

# Compile HPL with the updated Makefile
echo "Compiling HPL with OpenBLAS and OpenMPI..."
make clean arch=compile_BLAS_MPI
make arch=compile_BLAS_MPI

# Navigate to the compiled binary directory
echo "Navigating to the compiled binary directory..."
cd bin/compile_BLAS_MPI

# Edit HPL.dat for the new configuration
echo "Editing HPL.dat for single node, single CPU configuration..."
nano HPL.dat

echo "Make the following changes to your HPL.dat file:"
echo "Ps = 1"
echo "Qs = 1"
echo "Ns = 21976"
echo "NBs = 164"

# Run the HPL benchmark with the new configuration
echo "Running HPL benchmark with OpenBLAS and OpenMPI..."
./xhpl

echo "Benchmark complete. Please check the GFLOPS score displayed in the output."
