function chSTR = get_chSTR(chList)
% This function converts a list of integers that specify channels for
% stimulation into the decimal format required for the FNS stimulator. 
%
% Steps:
%   1. Convert channels from integers in a binary representation of 0's and
%   1's.
%   2. Change the binary string into a decimal format AFTER flipping the
%   vector L-R so that it meets the format requirements of FNS stimulator
%   (see FNS-16 Stimulator Instruction Manual)

% Inialize vector of 0's for all channels
chVec = zeros(1,16);
% Place a 1 in each index of chVec for channels in chList
chVec(chList+1) = 1;
% Convert binary list of channels to decimal in appopriate format for stim
chSTR = int2str(bin2dec(fliplr(int2str(chVec))));