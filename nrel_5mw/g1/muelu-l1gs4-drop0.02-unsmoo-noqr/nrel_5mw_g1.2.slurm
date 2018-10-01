#!/bin/bash

#SBATCH --nodes=1024
#SBATCH --time=3:00:00
#SBATCH --job-name=2.nrel_5mw_g1
#SBATCH --partition=regular
#SBATCH --constraint=haswell
#SBATCH --account=m2853
#SBATCH --output=out.%x_%j
#SBATCH -L SCRATCH,project
#SBATCH -q premium

#module load cmake/3.8.2
#module load zlib/1.2.8
#module load cray-parallel-netcdf/1.8.1.3
#module load cray-hdf5-parallel/1.10.1.1
#module load boost/1.63
#module load libxml2/2.9.3
#module load craype-haswell

ranks_per_node=32
mpi_ranks=$(expr $SLURM_JOB_NUM_NODES \* $ranks_per_node)
export OMP_NUM_THREADS=1  # = 272 / 68
export IOSS_PROPERTIES="INTEGER_SIZE_DB=8:INTEGER_SIZE_API=8"

#nalu_exec=/project/projectdirs/m2853/shreyas/exawind/install/Nalu/bin/naluX
nalu_exec=/project/projectdirs/m2853/shreyas/exawind/install/nalu-wind/bin/naluX
cd $SLURM_SUBMIT_DIR

nalu_input="nrel_5mw_g1.i"
nalu_log="nrel_5mw_g1.2.log"

echo "Working dir    = $PWD"
echo "Input file     = $nalu_input"
echo "Num. nodes     = $SLURM_JOB_NUM_NODES"
echo "Num. MPI Ranks = $mpi_ranks"
echo "Num. threads   = $OMP_NUM_THREADS"

srun -n ${mpi_ranks} -c ${OMP_NUM_THREADS} --cpu_bind=cores $nalu_exec -i ${nalu_input} -o ${nalu_log}
