
These Matlab functions and scripts accompany the article:

J. Schuurmans, E. de Vlugt, A.C. Schouten, Carel C. Meskers, Jurriaan H. de Groot and Frans C.T. van der Helm. "The monosynaptic Ia afferent pathway can largely explain the stretch duration effect of the long latency M2 response". Exp Brain Res (2009) 192:491-500.

The model simulates M1 and M2 responses after a sudden muscle stretch. To run the simulations:
1) run step1_runSimulations.m
2) run step2_analyzeResults.m
3) run step3_plotResults.m

Files (full descriptions are in the files' headers):
createRamp:             creates a ramp-shape stretch profile
M1area:                 calculates the metric for the M1
M2area:                 calculates the metric for the M2
RampModel:              the actual model
runspindle:             simulates the muscle spindle response to the stretch
SetSpindleConstants:    sets muscle spindle parameters
spindle_mileusnic:      muscle spindle model
step1_runSimulations:   runs the simulation
step2_analyzeResults:   analyzes the data
step3_plotResults:      plots the result

Author:     Jasper Schuurmans
Contact:    jasper@schuurmans.cc