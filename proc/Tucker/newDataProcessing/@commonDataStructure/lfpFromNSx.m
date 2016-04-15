function lfpFromNSx(cds)
    %takes a handle to a cds object and an NEVNSx structure, and populates
    %the LFP field of the cds
    
    %get list of channels that have LFP data:
    lfpList=find(~cellfun('isempty',strfind(lower(cds.NSxInfo.NSx_labels),'elec')));
    if ~isempty(lfpList)
        %get list of frequencies at which 
        freq=unique(cds.NSxInfo.NSx_sampling(lfpList));
        if length(freq)>1
            error('lfpFromNSx:multipleFrequencies','LFP data was collected at multiple frequencies and lfpFromNSx is not designed to handle this. Please update lfpFromNSx, or alias the lfp frequencies and handle this manually')
        end
        
        subset=find(cds.NSxInfo.NSx_sampling(lfpList)==freq);
        achanIndex=lfpList(subset);
        adata = [];%will preallocate below once we know how long the data is
        for c=1:length(achanIndex)
            if freq==500
                a = double(cds.NS1.Data(cds.NSxInfo.NSx_idx(achanIndex(c)),:))';
            elseif freq==1000
                a = double(cds.NS2.Data(cds.NSxInfo.NSx_idx(achanIndex(c)),:))';
            elseif freq==2000
                a = double(cds.NS3.Data(cds.NSxInfo.NSx_idx(achanIndex(c)),:))';
            elseif freq==10000
                a = double(cds.NS4.Data(cds.NSxInfo.NSx_idx(achanIndex(c)),:))';
            elseif freq==30000
                a = double(cds.NS5.Data(cds.NSxInfo.NSx_idx(achanIndex(c)),:))';
            end
            %recalculate time. allows force to be collected at
            %different frequencies on different channels at the
            %expense of execution speed
            t = (0:length(a)-1)' / cds.NSxInfo.NSx_sampling(achanIndex(c));

            %decimate and filter the raw force signals
            temp=decimateData([t a],filterConfig);
            %allocate the adata matrix if it doesn't exist yet
            if isempty(adata)
                adata=zeros(size(temp,1),numel(achanIndex));
            end
            adata(:,c)= temp(:,2);
        end    
        lfp=[temp(:,1),adata];
        labels=[{'t'},reshape(cds.NSxInfo.NSx_labels(lfpList(subset)),1,numel(cds.NSxInfo.NSx_labels(lfpList(subset))))];
        
        if ~isempty(lfp)
            %convert array to table:
            lfp=array2table(lfp,'VariableNames',labels);
            lfp.Properties.VariableUnits=[{'s'},repmat({'mV'},1,numel(lfpList))];
            lfp.Properties.VariableDescriptions=[{'time'},repmat({'LFP in mV'},1,numel(lfpList))];
            lfp.Properties.Description='Filtered LFP in raw collection voltage. Voltage scale is presumed to be mV';
            if isempty(cds.lfp)
                set(cds,'lfp',lfp);
            elseif ~isempty(lfp)
                cds.mergeTable('lfp',lfp)
            end
            evntData=loggingListenerEventData('lfpFromNSx',[]);
            notify(cds,'ranOperation',evntData)
        end
    end    
end