import post_process_nalu as ppn
import numpy as np
import os

equations = ["MomentumEQS", "ContinuityEQS", "myEnth", "myTke"]
meshRes   = np.array([40, 20, 10, 5])
# solvers   = ["gpu", "cpu"]

dirname_gpu = os.path.join(os.getcwd(), "May_01/gpu")
# dirname_cpu = os.path.join(os.getcwd(), "May_01/cpu")

filenames_gpu = ["ablNeutralEdge_rcb_" + "{:0>2}".format(res) + "m_CAM_sgs2_CFL_485_PR_re_7.0_nodrop_target_gpu.log" for res in meshRes]
# filenames_cpu = ["ablNeutralEdge_rcb_" + "{:0>2}".format(res) + "m_CAM_sgs2_CFL_485_PR_re_7.0_nodrop_target_cpu.log" for res in meshRes]

table_data = ppn.generate_scaling_data(dirname_gpu, filenames_gpu, equations, "max")
# print(table_data)

for idx, filename in enumerate(filenames_gpu):
    line = ""
    line = line + "{: >5}".format(int(table_data["num ranks"][idx])) + " & " + "{: >2}".format(meshRes[idx]) + "m &"
    for equation in ["MomentumEQS", "ContinuityEQS"]:
        line = line + "{: >7.2f}".format(table_data[equation]["initialization"][idx]) + " &"
        line = line + "{: >7.2f}".format(table_data[equation]["assembly"][idx]) + " &"
        line = line + "{: >7.2f}".format(table_data[equation]["load complete"][idx]) + " &"
        line = line + "{: >7.2f}".format(table_data[equation]["solve"][idx]) + " &"
        line = line + "{: >5}".format(table_data[equation]["linear iterations"][idx]) + " &"
    line = line + " \\\\"
    print(line)

print("")

for idx, filename in enumerate(filenames_gpu):
    line = ""
    line = line + "{: >5}".format(int(table_data["num ranks"][idx])) + " & " + "{: >2}".format(meshRes[idx]) + "m &"
    for equation in ["myEnth", "myTke"]:
        line = line + "{: >7.2f}".format(table_data[equation]["initialization"][idx]) + " &"
        line = line + "{: >7.2f}".format(table_data[equation]["assembly"][idx]) + " &"
        line = line + "{: >7.2f}".format(table_data[equation]["load complete"][idx]) + " &"
        line = line + "{: >7.2f}".format(table_data[equation]["solve"][idx]) + " &"
        line = line + "{: >5}".format(table_data[equation]["linear iterations"][idx]) + " &"
    line = line + "{: >5.2f} \\\\".format(table_data["wall clock"][idx])
    print(line)

