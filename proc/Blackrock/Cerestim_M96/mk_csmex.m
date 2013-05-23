% do the mex build for csmex, interface to Blackrock Cerestim M96
mex -setup
mex -g csmex.cpp BStimAPI.lib
csmex('connect'); csmex('disconnect');
