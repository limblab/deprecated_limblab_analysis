% do the mex build for csmex, interface to Blackrock Cerestim M96
% mex -setup
fprintf('BUILDING csmex....')
mex -g csmex.cpp BStimAPI.lib
fprintf('\nNow connect & disconnect to Cerestim\n***********************\n')
csmex('connect'); csmex('disconnect');
