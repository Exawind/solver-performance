
# ECP Solver Performance mesh directory

All meshes used for the solver benchmarking efforts are stored within this
directory under the benchmark problem directories. Due to the size of the
meshes, they are stored separately on various HPC systems within the
`ECPSolverPerformance/meshes` directory under the common projects area. Please
consult the README files under the `meshes/<PROBLEM>`, e.g.,
`meshes/V27/README.md`, for details on the meshes.

## Initializing the meshes 

```
# Clone the latest git repo 
cd $SCRATCH # Change to working directory
git clone https://github.com/NaluCFD/ECPSolverPerformance
cd ECPSolverPerformance/

# Copy the mesh files
cp -R ${SCRATCH}/ECPSolverPerformance/meshes/* meshes/
```

