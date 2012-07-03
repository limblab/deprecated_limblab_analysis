function tp = wf_trial_parameters(bdf)


% Gonna need to put this function in convertBDF2binned


% Make this a struct
% Epochs
%   Center hold time
%   Target hold time
%   Delay time
%   Reach time

% TargetInfo
% Target No  % x  % y  %h  %w


epochs = {'Center hold time', 'Target hold time', 'Delay'; 1, 2, 3};
     
     
%trial Parameters is a struct
trialParameters = struct('epochs',epochs,...
                         'targetInfo',targetinfo);


end