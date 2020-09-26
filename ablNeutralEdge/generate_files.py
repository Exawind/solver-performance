#!/usr/bin/env python
"""
Run this to generate the input files
You will need aprepro in the path when you execute

- 'python setup.py' will generate the ablNeutralEdge cases

- 'python setup.py /path/to/build/dir' will
generate the actuatorLine cases
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


if __name__ == '__main__':
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
    else:
        base_name = "ablNeutralEdge"
        time_step_scaling = 1.0

    cases = []
    for i in range(len(mesh_size)):
        cases.append({"ms" : mesh_size[i], "ts" : time_step[i]*time_step_scaling})

    for case in cases:
        command = ["aprepro", "-c#", "meshsize='{ms}'".format(ms=case["ms"]),
                   "timestep={ts}".format(ts=case["ts"]),
                    "use_actuator={ua}".format(ua=use_actuator), input_file,
                    output_file.format(ms=case["ms"], base=base_name)]

        print(command)

        # python 2 support since we are slow to update
        subprocess.check_call(command)
        subprocess.call(command)

        # create OpenFAST input files
        # use python because OpenFAST files don't play nice with aprepro
        if use_actuator:
            with  open(os.path.join(nrel5mw_base_dir, 'nrel5mw.fst'), 'r') as source:
                data = source.read()
                for i in range(1,3):
                    fname = "nrel5mw_{ind}_{ms}.fst".format(ms=case["ms"], ind=i)
                    with open(fname, 'w') as target:
                        totaltime = data.replace(r"0.62500", str(case["ts"]*10))
                        timestep = totaltime.replace(r"0.00625", str(case["ts"]/10))
                        chkpt = timestep.replace(r"0.0625", str(case["ts"]*10))
                        servofile = chkpt.replace(
                            os.path.join(nrel5mw_base_dir, r'5MW_Baseline','NRELOffshrBsline5MW_Onshore_ServoDyn.dat'),'ServoDyn.dat')
                        target.write(servofile)
