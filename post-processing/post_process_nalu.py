#!/usr/bin/python

import numpy as np
import os

def parse_nalu_log(filename, equations, metric):
    # Step 0: based on the metric chosen: avg, min or max
    # set the correct offset when reading in data from log
    offsets = dict({("avg", 3), ("min", 5), ("max", 7)})
    offset  = offsets[metric]

    # Step 1: read data from file
    fi = open(filename, "r")
    data = fi.readlines()
    fi.close()

    # Step 2: count total linear iterations per equation
    numLinIters = np.zeros(len(equations), dtype=np.int32)
    times       = np.zeros((len(equations), 8))
    for lineIdx in range(len(data)):
        line = data[lineIdx]
        if("STKPERF: Total Time:" in line):
            wallclock = float(line.split("STKPERF: Total Time:")[1])
        if "Simulation Shall Commence: number of processors =" in line:
            numRanks = int(line.split("=")[1])
        if line.split():
            for eqIdx, equation in enumerate(equations):
                if(line.split()[0] == equation):
                    numLinIters[eqIdx] += int(line.split()[1])

                if("Timing for Eq: "+equation in line):
                    init     = data[lineIdx + 1]
                    assemble = data[lineIdx + 2]
                    load     = data[lineIdx + 3]
                    solve    = data[lineIdx + 4]
                    precond  = data[lineIdx + 5]
                    misc     = data[lineIdx + 6]
                    iters    = data[lineIdx + 7]
                    times[eqIdx, 0] = float(init.split()[offset])
                    times[eqIdx, 1] = float(assemble.split()[offset])
                    times[eqIdx, 2] = float(load.split()[offset])
                    times[eqIdx, 3] = float(solve.split()[offset])
                    times[eqIdx, 4] = float(precond.split()[offset + 1])
                    times[eqIdx, 5] = float(misc.split()[offset])
                    times[eqIdx, 6] = times[eqIdx, 0] + times[eqIdx, 1] + times[eqIdx, 2] + times[eqIdx, 3] + times[eqIdx, 4] + times[eqIdx, 5]
                    times[eqIdx, 7] = float(iters.split()[offset + 1])

    simData = dict()
    for eqIdx, equation in enumerate(equations):
        eqDict = dict()
        eqDict["total linear iterations"] = numLinIters[eqIdx]
        eqDict["linear iterations"]       = times[eqIdx, 7]
        eqDict["initialization"]          = times[eqIdx, 0]
        eqDict["assembly"]                = times[eqIdx, 1]
        eqDict["load complete"]           = times[eqIdx, 2]
        eqDict["solve"]                   = times[eqIdx, 3]
        eqDict["preconditioner setup"]    = times[eqIdx, 4]
        eqDict["misc"]                    = times[eqIdx, 5]
        eqDict["total"]                   = times[eqIdx, 6]

        simData[equation] = eqDict
    
    simData["wall clock"] = wallclock
    simData["num ranks"]  = numRanks

    return simData

def generate_scaling_data(dirname, filenames, equations, metric):
    output = dict()
    scaling_data = dict()
    equation_fields = ["initialization", "assembly", "load complete", "solve", "preconditioner setup", "misc", "linear iterations"]
    global_fields   = ["wall clock", "num ranks"]

    if(metric not in ["avg", "min", "max"]):
        print("metrix must be \"avg\", \"min\" or \"max\"")
        return
    
    # Step 1: Initial formatting easy to do based on file structure
    for filename in filenames:
        scaling_data[os.path.basename(filename)] = parse_nalu_log(os.path.join(dirname, filename), equations, metric)
        
    # Step 2: Reformatting of data for easy post-processing into
    # plots or tables.
    for equation in equations:
        output[equation] = dict()
        for field in equation_fields:
            output[equation][field] = np.zeros(len(filenames))
            for idx, filename in enumerate(filenames):
                output[equation][field][idx] =  scaling_data[os.path.basename(filename)][equation][field]
        output[equation]

    for field in global_fields:
        output[field] = np.zeros(len(filenames))
        for idx, filename in enumerate(filenames):
            output[field][idx] = scaling_data[os.path.basename(filename)][field]
                

    return output

if __name__ == "__main__":
    dirname   = os.path.join(os.getcwd(), "Jan_17")
    filenames = ["ablNeutralEdge_rcb_1.log",
                 "ablNeutralEdge_rcb_2.log",
                 "ablNeutralEdge_rcb_3.log",
                 "ablNeutralEdge_rcb_4.log",
                 "ablNeutralEdge_rcb_6.log"]
    equations = ["MomentumEQS", "ContinuityEQS"]

    myData = generate_scaling_data(dirname, filenames, equations)

    print(myData)
