function [dirF,dirFStd] = steady_state_force_dir(fY,fX)

dirF = mean(atan2(fY,fX));
dirFStd = std(atan2(fY,fX));