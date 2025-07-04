#!/bin/bash

echo ">>>>>>>>>>>> Configuring HPL with Intel oneAPI Toolkit..."

# Navigate to the HPL directory
cd ~/hpl

# Copy the setup configuration file as a template
echo ">>>>>>>>>>>> Copying setup configuration script..."
cp setup/Make.Linux_Intel64 ./

# Edit the configuration file to make use of the Intel oneAPI Toolkit
echo ">>>>>>>>>>>> Editing Make.Linux_Intel64..."
nano Make.Linux_Intel64

# Configure your `Make.Linux_Intel64` with the following settings:
# Ensure the following changes:
# - `CC       = mpiicx`
# - `OMP_DEFS = -qopenmp`
# - `CCFLAGS  = $(HPL_DEFS) -O3 -w -ansi-alias -z noexecstack -z relro -z now -Wall`

# Compile the HPL binary using the Intel oneAPI Toolkit
echo ">>>>>>>>>>>> Compiling HPL binary..."
make arch=Linux_Intel64

# Navigate back to the original directory
cd bin/Linux_Intel64

# Confirm if the HPL binary has been successfully compiled
if [ -f "./xhpl" ]; then
  echo ">>>>>>>>>>>> HPL binary compiled successfully."
  echo ">>>>>>>>>>>> You can now use the compiled HPL binary with your HPL.dat configuration file."
else
  echo ">>>>>>>>>>>> Failed to compile the HPL binary. Please check the configuration in Make.Linux_Intel64."
  exit 1
fi

# Now, reuse your `HPL.dat` from when you compiled OpenMPI and OpenBLAS from source.
echo ">>>>>>>>>>>> Compiling with `HPL.dat` configuration..."
nano HPL.dat

echo ">>>>>>>>>>>> HPL configuration complete. You can now run the benchmark with the HPL binary."

# Final note: Be sure that your environment is configured correctly using `source ~/intel/oneapi/setvars.sh`
./xhpl
