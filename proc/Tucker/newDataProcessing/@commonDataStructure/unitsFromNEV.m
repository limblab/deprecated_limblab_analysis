function unitsFromNEV(cds,opts)
    %takes a cds handle an NEVNSx object and an options structure and
    %populates the units field of the cds
    unitList = unique([cds.NEV.Data.Spikes.Electrode;cds.NEV.Data.Spikes.Unit]','rows');
    %establish id table
    if isfield(opts,'array')
        array=opts.array;
    else
        warning('unitsFromNEV:noArrayName','The user did not specify an array name for this data. Please re-load the data and specify an array name')
        cds.addProblem('arrayNameUnknown: the user did not specify a name for the array this data comes from')
        array='?';
    end
    if isfield(opts,'monkey')
        monkey=opts.monkey;
    else
        warning('unitsFromNEV:noArrayName','The user did not specify an monkey name for this data. Please re-load the data and specify an array name')
        cds.addProblem('monkeyNameUnknown: the user did not specify a name for the monkey this data comes from')
        monkey='?';
    end
    %if we already have unit data, check that our new units come from a
        %different source so that we don't get duplicate entries
    if ~isempty(cds.units) && ~isempty(unitList) && ~isempty(find(strcmp({cds.units.array},opts.array),1,'first'))
        error('unitsFromNEV:sameArrayName','the cds and the current data have the same array name, which will result in duplicate entries in the units field. Re-load one of the data files using a different array name to avoid this problem')
    end
    
    %initialize struct array:
    cds.units=struct('chan',cell(numel(unitList),0),...
                            'ID',cell(numel(unitList),0),...
                            'array',cell(numel(unitList),0),...
                            'wellSorted',cell(numel(unitList),0),...this is a stub as testSorting can't be run till the whole units field is populated
                            'monkey',cell(numel(unitList),0),...
                            'spikes',repmat( cell2table(cell({0,2}),'VariableNames',{'ts','wave'}),numel(unitList),1));
    %loop through and unit entries for each unit
    for i = 1:size(unitList,1)
        %we are avoiding using the set methor here in order to avoid
        %unnecessary duplication of data in memory.
%         cds.units(i)=struct('chan',unitList(i,1),...
%                             'ID',unitList(i,2),...
%                             'array',array,...
%                             'wellSorted',false,...this is a stub as testSorting can't be run till the whole units field is populated
%                             'monkey',monkey,...
%                             'spikes',table(...timestamps for current unit from the NEV:
%                                      [double(cds.NEV.Data.Spikes.TimeStamp(cds.NEV.Data.Spikes.Electrode==unitList(i,1) & ...
%                                         cds.NEV.Data.Spikes.Unit==unitList(i,2)))/30000]',... 
%                                     ...waves for the current unit from the NEV:    
%                                     double(cds.NEV.Data.Spikes.Waveform(:,cds.NEV.Data.Spikes.Electrode==unitList(i,1) ...
%                                     &  cds.NEV.Data.Spikes.Unit==unitList(i,2))'),...
%                                     'VariableNames',{'ts','wave'}));
        cds.units(i).chan=unitList(i,1);
        cds.units(i).ID=unitList(i,2);
        cds.units(i).array=array;
        cds.units(i).wellSorted=false;
        cds.units(i).monkey=monkey;
        cds.units(i).spikes=table(...timestamps for current unit from the NEV:
                                     [double(cds.NEV.Data.Spikes.TimeStamp(cds.NEV.Data.Spikes.Electrode==unitList(i,1) & ...
                                        cds.NEV.Data.Spikes.Unit==unitList(i,2)))/30000]',... 
                                    ...waves for the current unit from the NEV:    
                                    double(cds.NEV.Data.Spikes.Waveform(:,cds.NEV.Data.Spikes.Electrode==unitList(i,1) ...
                                    &  cds.NEV.Data.Spikes.Unit==unitList(i,2))'),...
                                    'VariableNames',{'ts','wave'});
        %check for resets in time vector
        idx=cds.skipResets(cds.units(i).spikes.ts);
        if ~isempty(idx) && idx>1
            %if there were resets, remove everything before the resets
            cds.units(i).spikes{1:idx,:}=[];
        end
        
    end
%    unitscds.testSorting; %tests each sorted unit to see if it is well-separated from background and other units on the same channel
    opData.array=array;
    opData.numUnitsAdded=size(unitList,1);
    evntData=loggingListenerEventData('unitsFromNEV',opData);
    notify(cds,'ranOperation',evntData)
end