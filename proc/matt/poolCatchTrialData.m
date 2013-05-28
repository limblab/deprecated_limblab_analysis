function [trialTable, force, neural] = poolCatchTrialData(fileList)
% Give a list of files and it will pool all force and trial data from them
% fileList: cell array of string filenames
%
% Note: the code currently assumes that any continuous brain control file
% will have "IsoBC" somewhere in the title. Since it will group all data
% together (CT, HC, BC) this is useful because it can mark them as separate
% trials in the trial table 11th column via 1, 0, or 2 respectively.

% The code expects a cell
if ~iscell(fileList)
    fileList = {fileList};
end

% We want all of the time indexing based on some relative zero
maxTime = 0;

trialTable = [];
forcedata = [];
for iFile = 1:length(fileList)
    % Determine if this is a continuous BC trial
    if strfind(lower(fileList{iFile}),'isobc')
        BCTrial = true;
    else
        BCTrial = false;
    end
    
    load(fileList{iFile});
    
    temptable = getCatchTrialTable(out_struct,BCTrial);
    temptable(:,[1,6,7,8]) = temptable(:,[1,6,7,8])+maxTime;
    
    tempforce = out_struct.force.data;
    tempforce(:,1) = tempforce(:,1) + maxTime;
    
    trialTable = [trialTable; temptable];
    forcedata = [forcedata; tempforce];
    
    % Pool together the neural spike times
    for i = 1:length(out_struct.units)
        tempneural = out_struct.units(i).ts;
        tempneural = tempneural+maxTime;
        
        if iFile == 1
            neural(i).ts = tempneural;
            neural(i).id = out_struct.units(i).id;
        else
            neural(i).ts = [neural(i).ts; tempneural];
        end
    end
    
    maxTime = max(tempforce(:,1));
    
end

force.data = forcedata;
