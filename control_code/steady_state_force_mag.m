function [magForce,stdForce,fX,fY] = steady_state_force_mag(dataNEW,platON,platOFF)

fX = dataNEW(platON:platOFF,1);
fY = dataNEW(platON:platOFF,2);
magForce = mean(sqrt(fX.^2+fY.^2));
stdForce = std(sqrt(fX.^2+fY.^2));