#!/bin/bash

# Unset previous environment variables to start fresh
unset LD_LIBRARY_PATH
unset PATH
# Set the required environment variables
export PATH=/bin:/usr/bin:/home/ubuntu/opt/openmpi/bin:$PATH
export LD_LIBRARY_PATH=/home/ubuntu/opt/openmpi/lib:/opt/intel/oneapi/compiler/2024.2/lib:$LD_LIBRARY_PATH

# Verify the changes
echo "PATH: $PATH"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

# Make the changes persistent by adding to .bashrc
echo 'export PATH=/bin:/usr/bin:/home/ubuntu/opt/openmpi/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/home/ubuntu/opt/openmpi/lib:/opt/intel/oneapi/compiler/2024.2/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# Reminder of next steps
echo "Next steps:"
echo "1. After running the script on each node, verify the environment variables:"
echo "    - Run 'echo \$PATH' to check the PATH"
echo "    - Run 'echo \$LD_LIBRARY_PATH' to check the LD_LIBRARY_PATH"
echo "2. If everything is correct, proceed with running your MPI jobs across nodes."
echo "    - Use 'mpirun' or your preferred MPI command to execute across the cluster."
echo "    - Example: mpirun -np 4 ./your_mpi_program"
echo "3. If issues arise, double-check the environment setup and ensure OpenMPI is properly installed."
