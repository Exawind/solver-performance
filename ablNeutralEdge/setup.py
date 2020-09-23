#!/usr/bin/env
"""
Run this to generate the input files
You will need aprepro in the path when you execute

'python setup.py' will generate the ablNeutralEdge cases
'python setup.py /absolute/path/to/installed/reg_test/for/nrewl5MWactuatorLine' will
generate the actuatorLine cases
"""
import sys
import os
import subprocess

mesh_size = ["02", "05", "10", "20", "40"]
time_step = [0.15,  0.3,  0.6,  1.2,  2.4]
cases = []

for i in range(len(mesh_size)):
    cases.append({"ms" : mesh_size[i], "ts" : time_step[i]})

input_file = "input.yaml"
output_file = "{base}_{ms}m_sgs2_CFL_485.yaml"

if len(sys.argv) > 1:
    use_actuator = True
    base_name = "nrel5MWactuatorLine"
    nrel5mw_base_dir = sys.argv[1]

    with open(os.path.join(nrel5mw_base_dir, '5MW_Baseline','NRELOffshrBsline5MW_Onshore_ServoDyn.dat'), 'r') as source:
        fname = 'ServoDyn.dat'
        with open(fname, 'w') as target:
            data = source.read()
            pcmode = data.replace(r"5   PCMode", r"0   PCMode")
            target.write(pcmode)
else:
    use_actuator = ""
    base_name = "ablNeutralEdge"

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
    if use_actuator != "":
        with  open(os.path.join(nrel5mw_base_dir, 'nrel5mw.fst'), 'r') as source:
            for i in range(1,3):
                fname = "nrel5mw_{ind}_{ms}.fst".format(ms=case["ms"], ind=i)
                with open(fname, 'w') as target:
                    data = source.read()
                    totaltime = data.replace(r"0.62500", str(case["ts"]*10))
                    timestep = totaltime.replace(r"0.00625", str(case["ts"]/4))
                    print(nrel5mw_base_dir + r'/5MW_Baseline/NRELOffshrBsline5MW_Onshore_ServoDyn.dat')
                    servofile = timestep.replace(os.path.join(nrel5mw_base_dir, r'5MW_Baseline','NRELOffshrBsline5MW_Onshore_ServoDyn.dat'),'ServoDyn.dat')
                    target.write(servofile)
