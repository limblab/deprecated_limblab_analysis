function appendTable(trials,data)
    %appendTrials is a method of the trialData class, and should be
    %saved in the @trialData folder with the class definition
    
    if isempty(trials.data)
        %just put the new trials in the field
        set(trials,'data',data)
    else
        %get the column index of timestamp or time, whichever this
        %table is using:
        mask=cell2mat({strcmp(data.Properties.VariableNames,'t')});
        data{:,mask}=data{:,mask}+trials.meta.fileSepShift;
        set(trials,'data',[trials.data;data]);
    end
end