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


export init=input
export mini_prefix=mini
export equi_prefix=nvt
export prod_prefix=npt


# Minimization
# In the case that there is a problem during minimization using a single precision of GROMACS, please try to use
# a double precision of GROMACS only for the minimization step.
gmx grompp -f ${mini_prefix}.mdp -o ${mini_prefix}.tpr -c ${init}.gro -r ${init}.gro -p topol.top -n index.ndx -maxwarn -1
gmx_d mdrun -v -deffnm ${mini_prefix}


# Equilibration
gmx grompp -f ${equi_prefix}.mdp -o ${equi_prefix}.tpr -c ${mini_prefix}.gro -r ${init}.gro -p topol.top -n index.ndx
gmx mdrun -v -deffnm ${equi_prefix}



gmx grompp -f ${prod_prefix}.mdp -o ${prod_prefix}.tpr -c ${equi_prefix}.gro -p topol.top -n index.ndx
gmx mdrun -v -deffnm ${prod_prefix}


echo 12 | gmx energy -f mini.edr -o energy.xvg
echo 16 | gmx energy -f nvt.edr -o temp.xvg
echo 17 | gmx energy -f npt.edr -o pressure.xvg
