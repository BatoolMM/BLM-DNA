#!/bin/bash -l
# Use the current working directory
#SBATCH -D ./
# Use the current environment for this job.
#SBATCH --export=ALL
# Define job name
#SBATCH -J GROMACS
# Define a standard output file. When the job is running, %u will be replaced by user name,
# %N will be replaced by the name of the node that runs the batch script, and %j will be replaced by job id number.
#SBATCH -o gromacs.%u.%N.%j.out
# Define a standard error file
#SBATCH -e gromacs.%u.%N.%j.err
# Request the partition
#SBATCH -p phi
# Request the number of nodes
#SBATCH -N 1
# Specify the number of tasks per node
#SBATCH --ntasks-per-node=8
# Specify the number of tasks
##SBATCH --ntasks=16 #this option is not set as we have already set --ntasks-per-node
# Request the number of cpu per task
##SBATCH --cpus-per-task=32
# This asks for 3 days
#SBATCH -t 3-00:00:00
# Specify memory per core
##SBATCH --mem-per-cpu=9000M #this option is not set as we will just use the default for this partition
# Insert your own username to get e-mail notifications
#SBATCH --mail-user=batool@liverpool.ac.uk
# Notify user by email when certain event types occur
#SBATCH --mail-type=ALL

#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
module purge
module load apps/gromacs_double/2019.3/gcc-5.5.0+openmpi-1.10.7+fftw3_double-3.3.4+atlas-3.10.3
module load apps/gromacs/5.1.4/gcc-5.5.0+openmpi-1.10.7+fftw3_float-3.3.4+fftw3_double-3.3.4


echo 12 | gmx energy -f step4.0_minimization.edr -o energy.xvg
echo 16 | gmx energy -f step4.1_equilibration.edr -o temp.xvg
echo 17 | gmx energy -f step4.1_equilibration.edr -o pressure.xvg
