#!/bin/bash -l
#
# Example batch script to refine V27_41 mesh from R0 to R1
#

#SBATCH -p debug
#SBATCH -N 64
#SBATCH -t 00:30:00
#SBATCH -J V27_41_R1
#SBATCH -L SCRATCH
#SBATCH -C haswell
#SBATCH -A m2853


####### Input parameters
input_mesh=./V27_41_R0.exo
output_mesh=./V27_41_R1.exo

# Function for printing and executing commands
cmd() {
  echo "+ $@"
  eval "$@"
}

set -e

cmd "module load /global/project/projectdirs/m2853/jsrood/percept/spack/share/spack/modules/cray-CNL-haswell/percept-master-gcc-6.3.0-w3tkmsn"

(set -x; srun -n 2048 mesh_adapt --respect_spacing=0 --refine=DEFAULT --ioss_read_options="auto-decomp:yes" --ioss_write_options="large,auto-join:yes" --input_mesh=${input_mesh} --output_mesh=${output_mesh} --number_refines=1 --smooth_geometry=0 --progress_meter=1)
