function analogFromNSx(cds)
%takes a cds handle and an NEVNSx object and populates the analog cell
%array of the cds. Does not return anything
    %establish lists for force, emg, lfp
    forceList = [find(~cellfun('isempty',strfind(lower(cds.NSxInfo.NSx_labels),'force_'))),...
                find(~cellfun('isempty',strfind(cds.NSxInfo.NSx_labels,'ForceHandle')))];
    lfpList=find(~cellfun('isempty',strfind(lower(cds.NSxInfo.NSx_labels),'elec')));
    emgList=find(~cellfun('isempty',strfind(lower(cds.NSxInfo.NSx_labels),'emg_')));
    %get lists of the analog data for each frequency & remove those we have already handled
    analogList=setxor(1:length(cds.NSxInfo.NSx_labels),emgList);
    analogList=setxor(analogList,forceList);
    analogList=setxor(analogList,lfpList);
    if ~isempty(analogList)
        %get our list of frequencies:
        frequencies=unique(cds.NSxInfo.NSx_sampling(analogList));
        if ~isempty(cds.analog)
            %get a list of the frequencies already in the cds so that we
            %can merge or add the fields from the cds to the new analog
            %data
            cdsFrequencies=zeros(1,length(cds.analog));
            for i=1:length(cds.analog)
                cdsFrequencies(i)=round(1/mode(diff(cds.analog{i}.t)));
            end
        else
            cdsFrequencies=[];
        end
        for i=1:length(frequencies)
            %find the channels that area actually at this frequency:
            subset=find(cds.NSxInfo.NSx_sampling(analogList)==frequencies(i));
            analogIdx=analogList(subset);
            %append data in the subset into a single matrix:
            a=[];
            for c=1:numel(subset)
                switch frequencies(i)
                    case 500
                    nsLabel='NS1';
                    case 1000
                        nsLabel='NS2';
                    case 2000
                        nsLabel='NS3';
                    case 10000
                        nsLabel='NS4';
                    case 30000
                        nsLabel='NS5';
                    otherwise
                        error('analogFromNSx:unexpectedFrequency',['this function is not set up to handle data with collection frequency: ',num2str(frequencies(i))])
                end
                numPts=numel(cds.(nsLabel).Data(cds.NSxInfo.NSx_idx(analogIdx(c)),:));
                a{c+1}=double(cds.(nsLabel).Data(cds.NSxInfo.NSx_idx(analogIdx(c)),:))';
            end
            %get a time vector t for this sampling frequency
            a{1} = ([0:length(a{2})-1]' / frequencies(i));
            %convert the matrix of data into a table:
            match=find(cdsFrequencies==frequencies(i),1);
            if ~isempty(match)
                temp=table(a{:},'VariableNames',[{'t'};cds.NSxInfo.NSx_labels(analogList(subset))]);
                temp.Properties.VariableDescriptions=[{'time'},repmat({'analog data'},1,numel(subset))];
                temp.Properties.Description=['table of analog data with collection frequency of: ', num2str(frequencies(i))];
                analogData{i}=mergeAnalogTables(a,cds.analog{match});
            else
                analogData{i}=table(a{:},'VariableNames',[{'t'},reshape(cds.NSxInfo.NSx_labels(analogList(subset)),1,numel(cds.NSxInfo.NSx_labels(analogList(subset))))]);
                analogData{i}.Properties.VariableDescriptions=[{'time'},repmat({'analog data'},1,numel(subset))];
                analogData{i}.Properties.Description=['table of analog data with collection frequency of: ', num2str(frequencies(i))];
            end
        end
    else
        analogData={};
    end
    %push the cell array of analog data tables into the cds:
    %cds.setField('analog',analogData)
    if ~isempty(analogData)
        if ~isempty(cds.analog)
            %find any frequencies that were in the cds but not in the new data and add them:
            for i=1:length(cds.analog)
                if isempty(find(frequencies==cdsFrequencies(i),1))
                    analogData=[analogData,cds.analog{i}];
                end
            end
        else
            set(cds,'analog',analogData)
        end
        
        evntData=loggingListenerEventData('analogFromNSx',[]);
        notify(cds,'ranOperation',evntData)
    end
end
function merged=mergeAnalogTables(table1,table2)
    %this local function is a copy of the mergeTables method of the cds.
    %Its copied here since the mergeTables method works on fields of the
    %cds that are tables, and cds.analog is a cell array requiring that the
    %function return the merged table into the proper cell and then setting
    %the cds field.
    tstart=table1.t(1);
    tend=table1.t(end);
    dt=table1.t(2)-tstart;
    
    tstart2=table2.t(1);
    tend2=table2.t(end);
    dt2=table2.t(2)-tstart2;
    %check our frequencies
    if dt~=dt2
        error('mergeTable:differentFrequency',['Field: ',fieldName,' was collected at different frequencies in the cds and the new data and cannot be merged. Either re-load both data sets using the same filterspec, or refilter the data in one of the cds structures using decimation to get to the frequencies to match'])
    end
    %check if we have duplicate columns:
    for j=1:length(table1.Properties.VariableNames)
        if ~strcmp(table1.Properties.VariableNames{j},'t') && ~isempty(find(cell2mat({strcmp(table2.Properties.VariableNames,table1.Properties.VariableNames{j})}),1,'first'))
            error('mergeTable:duplicateColumns',['the column label: ',table1.Properties.VariableNames{j},' exists in the ',fieldName,' field of both cds and new data. All columns in the cds and new data except time must have different labels in order to merge'])
        end
    end
    mask=cell2mat({~strcmp(table1.Properties.VariableNames,'t')});
    merged=[table1(find(table1.t>=max(tstart,tstart2),1,'first'):find(table1.t>=min(tend,tend2),1,'first'),:),...
       table1(find(table2.t>=max(tstart,tstart2),1,'first'):find(table2.t>=min(tend,tend2),1,'first'),(mask))];
end