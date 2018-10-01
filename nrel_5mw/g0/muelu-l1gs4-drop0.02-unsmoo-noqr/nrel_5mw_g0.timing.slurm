#!/bin/bash

#SBATCH --nodes=64
#SBATCH --time=03:00:00
#SBATCH --job-name=nrel_5mw
#SBATCH --partition=regular
#SBATCH -q premium
#SBATCH --constraint=haswell
#SBATCH --account=m2853
#SBATCH --output=out.%x_%j
#SBATCH -L SCRATCH,project

module load cmake/3.8.2
module load zlib/1.2.8
module load cray-parallel-netcdf/1.8.1.3
module load cray-hdf5-parallel/1.10.1.1
module load boost/1.63
module load libxml2/2.9.3
module load craype-haswell

ranks_per_node=32
mpi_ranks=$(expr $SLURM_JOB_NUM_NODES \* $ranks_per_node)
nalu_exec=/project/projectdirs/m2853/shreyas/exawind/install/nalu-wind/bin/naluX
nalu_input=nrel_5mw_g0.timing.i
nalu_log=nrel_5mw_g0.timing.log


export OMP_NUM_THREADS=1  # = 272 / 68

cd $SLURM_SUBMIT_DIR

echo "Working dir    = $PWD"
echo "Nalu exec      = ${nalu_exec}"
echo "Nalu input     = ${nalu_input}"
echo "Nalu log       = ${nalu_log}"
echo "Num. nodes     = $SLURM_JOB_NUM_NODES"
echo "Num. MPI Ranks = $mpi_ranks"
echo "Num. threads   = $OMP_NUM_THREADS"

srun -n ${mpi_ranks} -c ${OMP_NUM_THREADS} --cpu_bind=cores $nalu_exec -i ${nalu_input} -o ${nalu_log}
