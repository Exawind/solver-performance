import sys
import subprocess

config = sys.argv[1].strip().lower()

mesh_size = ["02", "04", "10", "20", "40"]
input_file = "input.yaml"
output_file = "{base}_{ms}m_sgs2_CFL_485.yaml"

if config == "actuator":
    use_actuator = "T"
    base_name = "nrel5MWactuatorLine"
else:
    use_actuator = ""
    base_name = "ablNeutralEdge"

for m in mesh_size:
    subprocess.run(["aprepro", "-c#", "mesh_size={ms".format(ms=m),
                   "use_actuator={ua}".format(use_actuator), input_file, output_file.format(ms=m, base=base_name))
