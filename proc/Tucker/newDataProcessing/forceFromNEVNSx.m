function forceFromNEVNSx(cds,NEVNSx,NSx_info,opts)
    %finds analog channels in the NEVNSx with labels indicating they
    %contain force data and parses them based on the options in opts and
    %the filters in the cds. Because the cds is a member of the handle
    %superclass, this function does not return anything
    t=[];
    force=[];
    handleforce=[];
    %forces for wf and other tasks that use force_ to denote force channels
    forceCols = find(~cellfun('isempty',strfind(lower(NSx_info.NSx_labels),'force_')));
    if ~isempty(forceCols)
        [loadCellData,t]=getFilteredAnalogMat(NEVNSx,NSx_info,cds.kinFilterConfig,forceCols);
        %build our table of force data:
        labels=cell(1,length(forceCols));
        for i=1:length(forceCols)
            %if we have x or y force, give the field our special
            %label so that later processing can find it easily
            if strcmpi(NSx_info.NSx_labels(forceCols(i)),'force_x')
                labels(i)={'fx'};
            elseif strcmpi(NSx_info.NSx_labels(forceCols(i)),'force_y')
                labels(i)={'fy'};
            else
                labels(i)=NSx_info.NSx_labels(forceCols(i));
            end
        end
        %truncate to deal with the fact that encoder data doesn't start
        %recordign till 1 second into the file and store in a table
        force=array2table(loadCellData(t>=1,:),'VariableNames',labels);
    end
    %forces for robot:
    if opts.robot
        force_channels = find(~cellfun('isempty',strfind(NSx_info.NSx_labels,'ForceHandle')));
        if length(force_channels)==6
            achan_index=-1*ones(1,6);
            for i=1:6
                achan_index(i)=find(~cellfun('isempty',strfind(NSx_info.NSx_labels,['ForceHandle',num2str(i)])));
            end
            %pull filtered analog data for load cell:
            [loadCellData,t]=getFilteredAnalogMat(NEVNSx,NSx_info,cds.kinFilterConfig,achan_index);
            %truncate to handle the fact that encoder data doesn't start
            %recording until 1 second into the file and convert load cell 
            %voltage data into forces
            handleforce=handleForceFromRaw(cds,loadCellData(t>=1,:),opts);
        else
            handleforce=[];
            warning('BDF:noForceSignal','No force handle signal found because calc_from_raw did not find 6 channels named ''ForceHandle*''');
        end
    end
    %write temp into the cds
    forces=[table(t(t>=1),'VariableNames',{'t'}),handleforce,force];
    if ~isempty(force)
        forces.Properties.VariableUnits=[{'s'} repmat({'N'},1,size(handleforce,2)+numel(labels))];
        forces.Properties.Description='a table containing force data. First column is time, all other columns will be forces. If possible forces in x and y are identified and labeled fx and fy';
        cds.setField('force', forces)
    else
        forces=cell2table(cell(0,3),'VariableNames',{'t','fx','fy'});
        forces.Properties.VariableUnits=[{'s'} repmat({'N'},1,size(handleforce,2)+size(force,2))];
        forces.Properties.Description='an empty table. No force data was found in the data source';
        cds.setField('force', forces)
    end
    cds.addOperation(mfilename('fullpath'),cds.kinFilterConfig)
end