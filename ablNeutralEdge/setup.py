"""
Run this to generate the meshes
You will need aprepro in the path when you execute

'python setup.py' will generate the ablNeutralEdge cases
add any additional commands and it will generate the actuator
cases
"""
import sys
import subprocess

config = ''
if len(sys.argv) > 1:
    config = sys.argv[1].strip().lower()

mesh_size = ["02", "05", "10", "20", "40"]
time_step = [0.15,  0.3,  0.6,  1.2,  2.4]
cases = []
for i in range(len(mesh_size)):
    cases.append({"ms" : mesh_size[i], "ts" : time_step[i]})

input_file = "input.yaml"
output_file = "{base}_{ms}m_sgs2_CFL_485.yaml"

if config == "actuator":
    use_actuator = "T"
    base_name = "nrel5MWactuatorLine"
else:
    use_actuator = ""
    base_name = "ablNeutralEdge"

for case in cases:
    command = ["aprepro", "-c#", "mesh_size='{ms}'".format(ms=case["ms"]), "timestep={ts}".format(ts=case["ts"]),
                    "use_actuator={ua}".format(ua=use_actuator), input_file,
                    output_file.format(ms=case["ms"], base=base_name)]
    print(command)
    subprocess.run(command)
