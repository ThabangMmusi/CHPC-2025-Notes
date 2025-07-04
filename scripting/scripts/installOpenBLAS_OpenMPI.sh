#!/bin/bash

# Exit on errors
set -e

# Display message helper
log() {
  echo ">>>>>>>>>>>> $1"
}

# Install prerequisites
log "Installing required dependencies..."
sudo apt update
sudo apt install -y build-essential hwloc libhwloc-dev libevent-dev gfortran wget

# Set up directories
INSTALL_DIR="$HOME/opt"
OPENBLAS_DIR="$INSTALL_DIR/openblas"
OPENMPI_DIR="$INSTALL_DIR/openmpi"
HPL_DIR="$HOME/hpl"

# Install OpenBLAS
log "Cloning and installing OpenBLAS..."
cd ~
git clone https://github.com/xianyi/OpenBLAS.git
cd OpenBLAS
git checkout v0.3.26
make
make PREFIX=$OPENBLAS_DIR install

# Install OpenMPI
log "Fetching and installing OpenMPI..."
cd ~
wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.4.tar.gz
tar xf openmpi-4.1.4.tar.gz
cd openmpi-4.1.4
CFLAGS="-Ofast -march=native -mtune=native" ./configure --prefix=$OPENMPI_DIR
make -j$(nproc)
make install

# Export environment variables for OpenMPI
log "Configuring environment for OpenMPI..."
export MPI_HOME=$OPENMPI_DIR
export PATH=$MPI_HOME/bin:$PATH
export LD_LIBRARY_PATH=$MPI_HOME/lib:$LD_LIBRARY_PATH

# Prepare HPL Makefile
log "Preparing HPL Makefile for OpenBLAS and OpenMPI..."
cd $HPL_DIR
cp Make.<TEAM_NAME> Make.compile_BLAS_MPI
sed -i 's|CC\s*=.*|CC = mpiicx|' Make.compile_BLAS_MPI
sed -i 's|CFLAGS\s*=.*|CFLAGS = -O3 -Wall -Wno-unused-function|' Make.compile_BLAS_MPI
sed -i 's|LDFLAGS\s*=.*|LDFLAGS = -L$HOME/opt/openblas/lib -lopenblas -lm|' Make.compile_BLAS_MPI
sed -i 's|LIBS\s*=.*|LIBS = -lpthread|' Make.compile_BLAS_MPI

# Compile HPL binary
log "Compiling HPL binary..."
make arch=compile_BLAS_MPI

# Create HPL.dat file
log "Creating HPL.dat configuration file..."
cd bin/compile_BLAS_MPI
cat > HPL.dat <<EOL
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
21976        Ns
1            # of NBs
164          NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
1            Ps
1            Qs
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
2            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
1            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOL

# Run HPL benchmark
log "Running HPL benchmark with OpenBLAS and OpenMPI..."
./xhpl

log "HPL benchmark complete. Check the output for GFLOPS performance."
