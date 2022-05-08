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
#SBATCH -p nodes
# Request the number of nodes
#SBATCH -N 2
# Specify the number of tasks per node
#SBATCH --ntasks-per-node=16
# Specify the number of tasks
##SBATCH --ntasks=16 #this option is not set here as we have already set --ntasks-per-node
# Request the number of cpu per task
#SBATCH --cpus-per-task=5
# This asks for 3 days
#SBATCH -t 3-00:00:00
# Specify memory per core
##SBATCH --mem-per-cpu=9000M #this option is not set as we will just use the default for this partition
# Insert your own username to get e-mail notifications
##SBATCH --mail-user=batool@liverpool.ac.uk
# Notify user by email when certain event types occur
#SBATCH --mail-type=ALL
#

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
module purge
module load apps/gromacs_double/2019.3/gcc-5.5.0+openmpi-1.10.7+fftw3_double-3.3.4+atlas-3.10.3


export init="step3_input"
export mini_prefix="step4.0_minimization"
export equi_prefix="step4.1_equilibration"
export prod_prefix="step5_production"
export prod_step="step5"

# Minimization
# In the case that there is a problem during minimization using a single precision of GROMACS, use 
# a double precision of GROMACS only for the minimization step.
gmx grompp -f ${mini_prefix}.mdp -o ${mini_prefix}.tpr -c ${init}.gro -r ${init}.gro -p topol.top -n index.ndx -maxwarn -1
mpirun gmx_mpi mdrun -ntomp $SLURM_CPUS_PER_TASK -v -s topol.tpr -deffnm ${mini_prefix}

# Equilibration
gmx grompp -f ${equi_prefix}.mdp -o ${equi_prefix}.tpr -c ${mini_prefix}.gro -r ${init}.gro -p topol.top -n index.ndx
mpirun gmx_mpi mdrun -ntomp $SLURM_CPUS_PER_TASK -v -s topol.tpr -deffnm ${equi_prefix} 

# MD run
gmx grompp -f ${prod_prefix}.mdp -c step4.1_equilibration.gro -t step4.1_equilibration.cpt -p topol.top -o one_ns.tpr -n index.ndx
mpirun gmx_mpi mdrun -ntomp $SLURM_CPUS_PER_TASK -v -s topol.tpr -deffnm one_ns 

