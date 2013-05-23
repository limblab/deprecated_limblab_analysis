% function cs_test(TRIGNUM)
% function to test Blackrock Cewrestim M96
% Configurations are per Tucker's email 4/9/13. There are two experiments;
% both involve a stimulus that is selected depending on a STIM word
% received from Cerebus.
%
% The first experiment is to simultaneously stimulate 4 electrodes with the
% same current, anodal first; the STIM word tells whether to use 5, 10, 15,
% or 20 µA. 
%
% The second experiment is to EITHER simultaneously stimulate at 4
% electrodes using 20 µA, OR stimulate at only one of the electrodes using
% 20 µA.
%
% There are 9 different STIM words corresponding to the 9 possibilities.
%
% The csmex commands mirror the function calls in the Blackrock Cerestim
% API.

clear
try
    [retval] = csmex('connect');
catch
    if retval~=-10  % code for already connected, fail for other error
        error('fail to initialize csmex')
    end
end

% TODO: We need a way for the user to select the 4 electrode numbers
e1=1; e2=2; e3=3; e4=4; % This is a placeholder for the user selection

% The configure command takes 9 parameters. This command establishes a
% configuration for the identified configID, the first paremeter, with 1-15
% possible IDs. Here we use only IDs 1-4.
csmex('configure', 1,0,60,5,5,200,200,200,53);
csmex('configure', 2,0,60,10,10,200,200,200,53);
csmex('configure', 3,0,60,15,15,200,200,200,53);
csmex('configure', 4,0,60,20,20,200,200,200,53);

% The chList array. We may want to choose these in a GUI.
chList=[e1 e2 e3 e4];

disp 'Ready to test! Try this command:'
disp 'for i=1:8,CfgPerTrig(i,chList);pause(0.3),end'