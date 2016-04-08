function handleforce=handleForceFromNEVNSx(raw_force,cds,enc,opts)
    % computes the handle force using the data in the NEVNSx object and
    % puts it into the correct field of the cds. since the cds is a member
    % of the handle superclass no variable needs to be passed back. Assumes
    % EXACTLY 6 channels will be flagged as ForceHandle channels. If there
    % less than 6, there will be columns of zeros returned. If more than 6
    % columns exist, names with duplication will be ignored, and channels
    % after the first 6 will be ignored silently
    %
    %There is no particular reason this needs to be a function, but it 
    %cleans up the main code to move it to this sub-function, and local
    %variables will be automatically cleared saving memory
        
    %calculate offsets for the load cell and remove them from the force:
    still=is_still(sqrt(cds.pos.x.^2+cds.pos.y.^2));
    if sum(still) > 100  % Only use still data if there are more than 100 movement free samples                
        force_offsets = mean(raw_force(still,:));
    else
        warning('NEVNSx2cds:noStillTime','Could not find 100 points of still time to compute load cell offsets. Defaulting to mean of force data')
        force_offsets = mean(raw_force);
    end

    % Get calibration parameters based on lab number            
    if isfield(opts,'labnum') 
        [fhcal,rotcal,Fy_invert]=getLabParams(opts.labnum,cds.meta.datetime,opts.rothandle);
    else
        error('calc_from_raw:LabNotSet','calc_from_raw needs the lab number in order to select the correct load cell calibration')
    end
    raw_force = (raw_force -  repmat(force_offsets, length(raw_force), 1)) * fhcal * rotcal;
    clear force_offsets;

    % fix left hand coords in some force data
    raw_force(:,2) = Fy_invert.*raw_force(:,2); 

    %rotate load cell data into room coordinates using robot arm
    %angle
    handleforce=zeros(size(raw_force(:,1),6));
    if isfield(opts,'labnum')&& opts.labnum==3 %If lab3 was used for data collection  
        table( raw_force(:,1).*cos(-enc(:,2))' - raw_force(:,2).*sin(enc(:,2))',...
            raw_force(:,1).*sin(enc(:,2))' + raw_force(:,2).*cos(enc(:,2))',...
            raw_force(:,3),...
            raw_force(:,4).*cos(-enc(:,2))' - raw_force(:,5).*sin(enc(:,2))',...
            raw_force(:,4).*sin(enc(:,2))' + raw_force(:,5).*cos(enc(:,2))',...
            raw_force(:,6),...
            'VariableNames',{'fx','fy','fz','mx','my','mz'});
    elseif isfield(opts,'labnum')&& opts.labnum==6 %If lab6 was used for data collection         
        table( raw_force(:,1).*cos(-enc(:,1))' - raw_force(:,2).*sin(enc(:,1))',...
            raw_force(:,1).*sin(enc(:,1))' + raw_force(:,2).*cos(enc(:,1))',...
            raw_force(:,3),...
            raw_force(:,4).*cos(-enc(:,1))' - raw_force(:,5).*sin(enc(:,1))',...
            raw_force(:,4).*sin(enc(:,1))' + raw_force(:,5).*cos(enc(:,1))',...
            raw_force(:,6),...
            'VariableNames',{'fx','fy','fz','mx','my','mz'});
    end
    evntData=loggingListenerEventData('handleForceFromNEVNSx',[]);
    notify(cds,'ranOperation',evntData)
end
