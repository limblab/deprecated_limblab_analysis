function lfpFromNEVNSx(cds,NEVNSx,NSxInfo)
    %takes a handle to a cds object and an NEVNSx structure, and populates
    %the LFP field of the cds
    
    %get list of channels that have LFP data:
    lfpList=find(~cellfun('isempty',strfind(lower(NSxInfo.NSx_labels),'elec')));
    if ~isempty(lfpList)
        %get list of frequencies at which 
        frequencies=unique(NSxInfo.NSx_sampling(lfpList));
        %loop through frequencies, get arrays of LFP data at the same
        %frequency, then filter and decimate to the common LFP frequency:
        lfp=[];
        labels=[];
        for i=1:length(frequencies)
            subset=find(NSxInfo.NSx_sampling(lfpList)==frequencies(i));
            [temp,t]=getFilteredAnalogMat(NEVNSx,NSxInfo,cds.lfpFilterConfig,lfpList(subset));
            if isempty(lfp)
                lfp=t;
                labels={'t'};
            end
            lfp=[lfp,temp];
            labels=[labels,NSxInfo.NSx_labels(lfpList(subset))];
        end
        if ~isempty(lfp)
            %convert array to table:
            lfp=array2table(lfp,'VariableNames',labels);
            lfp.Properties.VariableUnits={'s',repmat({'mV'},1,numel(lfpList))};
            lfp.Properties.VariableDescriptions={'time',repmat({'LFP in mV'},1,numel(lfpList))};
            lfp.Properties.Description='Filtered LFP in raw collection voltage. Voltage scale is presumed to be mV';
            %cds.setField('LFP',lfp)
            if isempty(cds.LFP)
                set(cds,'LFP',lfp)
            else
                cds.mergeTable('LFP',lfp)
            end
            cds.addOperation(mfilename('fullpath'))
        end
    end    
end