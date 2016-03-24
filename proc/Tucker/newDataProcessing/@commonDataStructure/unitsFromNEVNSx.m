function unitsFromNEVNSx(cds,NEVNSx,opts)
    %takes a cds handle an NEVNSx object and an options structure and
    %populates the units field of the cds
    unitList = unique([NEVNSx.NEV.Data.Spikes.Electrode;NEVNSx.NEV.Data.Spikes.Unit]','rows');
    %establish id table
    if isfield(opts,'array')
        array=opts.array;
    else
        warning('unitsFromNEVNSx:noArrayName','The user did not specify an array name for this data. Please re-load the data and specify an array name')
        cds.addProblem('ArrayNameUnknown: the user did not specify a name for the array this data comes from')
        array='?';
    end
    %if we already have unit data, check that our new units come from a
        %different source so that we don't get duplicate entries
    if ~isempty(cds.units) && ~isempty(unitList) && ~isempty(find(strcmp({cds.units.array},opts.array),1,'first'))
        error('unitsFromNEVNSx:sameArrayName','the cds and the current data have the same array name, which will result in duplicate entries in the units field. Re-load one of the data files using a different array name to avoid this problem')
    end
    
    %loop through and unit entries for each unit
    units=struct('chan',[],'ID',[],'array',array,'spikes',cell2table(cell(0,2),'VariableNames',{'ts','wave'}));
    for i = 1:size(unitList,1)
        %timestamps for current unit:
        ts = [double(NEVNSx.NEV.Data.Spikes.TimeStamp(NEVNSx.NEV.Data.Spikes.Electrode==unitList(i,1) & ...
                NEVNSx.NEV.Data.Spikes.Unit==unitList(i,2)))/30000]';
        %build waves table    
        waves = double(NEVNSx.NEV.Data.Spikes.Waveform(:,NEVNSx.NEV.Data.Spikes.Electrode==unitList(i,1) ...
            &  NEVNSx.NEV.Data.Spikes.Unit==unitList(i,2))');
        %check for resets in time vector
        idx=skip_resets(ts);
        if ~isempty(idx)
            %if there were resets, remove everything before the resets
            ts = units(i).ts(idx+1:end);
            waves = waves{i}(idx+1:end,:);
            clear idx;
        end
        units(i).chan=unitList(i,1);
        units(i).ID=unitList(i,2);
        units(i).array=array;
        units(i).spikes=table(ts,waves,'VariableNames',{'ts','wave'});
    end
    
    %append to existing units field
    set(cds,'units',[cds.units units])
    cds.addOperation(mfilename('fullpath'))
end