function [bad, badChanList]=checkLFP60hz(cds)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %
    %this function compares power at 55-65hz band to total power in the 
    %signal to test whether the signal is contaminated with 60cycle noise.
    %Allows the user to specify a threshold ratio, or will assign a default
    %if no threshold is supplied. If the ratio of power exceeds the
    %threshold, checkLFP60hz will insert an entry into cds.meta.known
    %problems, and return a value of 1. Otherwise checkLFP60hz will return
    %0
    lim=0.5;
    bad=0;
    badChanList=[];
    if ~isempty(varargin)
        lim=varargin{1};
    end
    RList=power60HzRatio(cds.LFP);
    badList=find(RList>lim)+1;
    for i=1:numel(badList)
        %make known problem entry
        cds.addProblem(['The LFP channel: ',cds.LFP.Properties.VariableNames{badList(i)},' has a very high 60hz power component. This channel may have been improperly connected, or may need a notch filter.'])
        %flag the EMG as bad
        bad=1;
        %enter the flag in the list
        badChanList=[badChanList,cds.LFP.Properties.VariableNames(badList(i))];
    end
end