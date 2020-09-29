#!/usr/bin/env python
"""
Run this to generate the input files
You will need aprepro in the path when you execute

- 'python setup.py' will generate the ablNeutralEdge cases

- 'python setup.py /path/to/build/dir' will
generate the actuatorLine cases
for these you will also need abl_mesh from wind_utils in
your path
"""
import sys
import os
import subprocess

# parameters
use_actuator = False
install_path = ''
mesh_size = ["02", "05", "10", "20", "40"]
time_step = [0.15,  0.3,  0.6,  1.2,  2.4]
input_file = "input.yaml"
output_file = "{base}_{ms}m_sgs2_CFL_485.yaml"
pregenmesh = "/gpfs/alpine/cfd116/proj-shared/meshes/ablNeutralEdge/{meshsize}m/abl_5km_5km_1km_neutral_{meshsize}m.g"
max_num_actuators = 4

def run_command(command, verbose=True):
    if verbose:
        print(command)
    # python 2 support since we are slow to update
    subprocess.check_call(command)
    subprocess.call(command)



if __name__ == '__main__':
    cases = []
    for i in range(len(mesh_size)):
        # setup base line cases
        cases.append({"ms" : mesh_size[i],
                      "ts" : time_step[i],
                      "numAct" : 1,
                      "genMesh" : False,
                      "mf" : pregenmesh.format(meshsize = mesh_size[i]),
                      "epsilon" : 5.0,
                      "lengthScale" : 5000.0
                      })

    if len(sys.argv) > 1:
        # can specify install path as a command line arg or change parameters above
        install_path = sys.argv[1]
        use_actuator = True

    # ensure absolute path
    install_path = os.path.abspath(install_path)

    if use_actuator:
        if not os.path.isdir(install_path):
            sys.exit("ERROR: {ip} is not a valid directory".format(ip=install_path))

        base_name = "nrel5MWactuatorLine"
        nrel5mw_base_dir = os.path.join(install_path, "reg_tests/test_files/nrel5MWactuatorLine")
        time_step_scaling = 1e-1
        servo_file = os.path.join(nrel5mw_base_dir, '5MW_Baseline','NRELOffshrBsline5MW_Onshore_ServoDyn.dat')

        if not os.path.isfile(servo_file):
            sys.exit("ERROR: {sf} does not exist.\n"
                "Your install may be missing EANBLE_TESTS or ENABLE_OPENFAST".format(sf=servo_file))

        with open(servo_file, 'r') as source:
            fname = 'ServoDyn.dat'
            # replace parameters to use simple variable speed torque controller
            with open(fname, 'w') as target:
                data = source.read()
                data = data.replace(r"5   PCMode", r"0   PCMode")
                data = data.replace(r"2   GenModel", r"1   GenModel")
                data = data.replace(r"5   VSContrl", r"1   VSContrl")
                data = data.replace(r"9999.9   VS_RtGnSp", r"1161.96   VS_RtGnSp")
                data = data.replace(r"9999.9   VS_RtTq", r"43093.55   VS_RtTq")
                data = data.replace(r"9999.9   VS_Rgn2K", r"0.025576   VS_Rgn2K")
                data = data.replace(r"9999.9   VS_SlP", r"10.0   VS_SlP")
                target.write(data)

        # add weak scaling growing domain to cases
        for i in range(max_num_actuators):
            cases.append({"ms" : 10,
                         "ts" : 0.6,
                         "numAct" : 2**i,
                         "genMesh" : True,
                         "mf" : "abl_l{xlen}x{ylen}x{zlen}m_n{meshsize}m.g",
                         "epsilon" : 25.0,
                         "lengthScale" : 1000.0,
                         "basename" : "weakScaling_n{nt}".format(nt=i)
                         })
    else:
        base_name = "ablNeutralEdge"
        time_step_scaling = 1.0

    # add extra stuff
    for case in cases:
        case["ts"] *= time_step_scaling

    for case in cases:
        if case["genMesh"]:
            # construct able_mesh input
            command = ["aprepro", "-c#",
                       "xlen={x}".format(x=case["lengthScale"]*case["numAct"]),
                       "ylen={y}".format(y=case["lengthScale"]),
                       "zlen={z}".format(z=case["lengthScale"]),
                       "meshsize={ms}".format(ms=case["ms"]),
                       "mesh_generator_base.yaml",
                       "abl_mesh_inp{nt}.yaml".format(nt=case["numAct"])]
            run_command(command)

            # generate mesh file
            run_command(["abl_mesh", "-i", "abl_run{nt}.yaml".format(nt=case["numAct"])])


        # construct input deck
        if "basename" in case.keys():
            base_name = case["basename"]

        command = ["aprepro", "-c#",
                   "meshfile={mf}".format(mf=case["mf"]),
                   "meshsize='{ms}'".format(ms=case["ms"]),
                   "timestep={ts}".format(ts=case["ts"]),
                   "use_actuator={ua}".format(ua=use_actuator),
                   "epsilon={eps}".format(eps=case["epsilon"]),
                   "length={l}".format(l=case["lengthScale"]),
                   "nturbines={nt}".format(nt=case["numAct"]),
                   input_file,
                   output_file.format(ms=case["ms"],base=base_name)]

        run_command(command)


        # create OpenFAST input files
        # use python because OpenFAST files don't play nice with aprepro
        if use_actuator:
            with  open(os.path.join(nrel5mw_base_dir, 'nrel5mw.fst'), 'r') as source:
                data = source.read()
                for i in range(1,case["numAct"]+1):
                    fname = "nrel5mw_{ind}_{ms}.fst".format(ms=case["ms"], ind=i)
                    with open(fname, 'w') as target:
                        totaltime = data.replace(r"0.62500", str(case["ts"]*10))
                        timestep = totaltime.replace(r"0.00625", str(case["ts"]/10))
                        chkpt = timestep.replace(r"0.0625", str(case["ts"]*10))
                        servofile = chkpt.replace(
                            os.path.join(nrel5mw_base_dir, r'5MW_Baseline','NRELOffshrBsline5MW_Onshore_ServoDyn.dat'),'ServoDyn.dat')
                        target.write(servofile)
