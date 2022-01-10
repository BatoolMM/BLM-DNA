#!/bin/bash -l
#SBATCH -D ./
#SBATCH --export=ALL
#SBATCH --nodes=2
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=5
##SBATCH --mail-user=batool@liverpool.ac.uk
##SBATCH --mail-type=ALL
#SBATCH -t 3-00:00:00
#SBATCH -p nodes

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
module purge
module load apps/gromacs_cuda/5.1.4/gcc-5.5.0+openmpi-1.10.7+fftw3_float-3.3.4+nvidia-cuda-8.0.61

export BLM_DNA_WT=$MD

#Changing the names of the CHARMM-GUI files
mv step3_input.gro input.gro
mv step3_input.pdb input.pdb
mv step3_input.psf input.psf
mv step4.0_minimization.mdp em.mdp
mv step4.1_equilibration.mdp nvt.mdp
mv step5_production.mdp md_1ns.mdp 


export init="input"
export mini_prefix="em"
export equi_prefix="nvt"
export prod_prefix="npt"


# Minimization
# In the case that there is a problem during minimization using a single precision of GROMACS, please try to use 
# a double precision of GROMACS only for the minimization step.
gmx grompp -f ${mini_prefix}.mdp -o ${mini_prefix}.tpr -c ${init}.gro -r ${init}.gro -p topol.top -n index.ndx -maxwarn -1
mpirun -np $SLURM_NTASKS  gmx_mpi mdrun -ntomp $SLURM_CPUS_PER_TASK -v -s -deffnm ${mini_prefix} 


# Equilibration in NVT
gmx grompp -f ${equi_prefix}.mdp -o ${equi_prefix}.tpr -c ${mini_prefix}.gro -r ${init}.gro -p topol.top -n index.ndx
mpirun -np $SLURM_NTASKS  gmx_mpi mdrun -ntomp $SLURM_CPUS_PER_TASK -v -s -deffnm ${equi_prefix} 

# Equilibration in NPT
gmx grompp -f ${prod_prefix}.mdp -o ${prod_prefix}.tpr -c ${equi_prefix}.gro -t ${equi_prefix}.cpt -p topol.top -n index.ndx
mpirun -np $SLURM_NTASKS gmx_mpi mdrun -ntomp $SLURM_CPUS_PER_TASK -v -s -deffnm ${prod_prefix}


