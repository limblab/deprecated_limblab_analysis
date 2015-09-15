function [bdf_DL,bdf_PM,bdf] = split_workspaces(folder, options)
% SPLIT_WORKSPACES Splits a Random Walk dataset into a
% distal-lateral workspace and a proximal-medial workspace to compare the
% tunings in the two.

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK IF OUTPUT BEHAVIORS HAS A SET OF ZEROS WHERE THERE SHOULD BE
% NOTHING
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~isfield(options,'bdf'))
    if(folder(end)==filesep)
        folder = folder(1:end-1);
    end
    
    NSx = cerebus2NEVNSx(folder,options.prefix);
    bdf = get_nev_mat_data(NSx,options.labnum);
else
    bdf = options.bdf;
end

pos = bdf.pos;

DL_ind = pos(:,2)<mean(pos(:,2)) & pos(:,3)>mean(pos(:,3));
PM_ind = pos(:,2)>mean(pos(:,2)) & pos(:,3)<mean(pos(:,3));

bdf_DL = extract_workspace(bdf,DL_ind);
bdf_PM = extract_workspace(bdf,PM_ind);

end

function [bdf_new,iStart,iStop] = extract_workspace(bdf,ind)
    bdf_new = bdf;
    t = bdf.pos(:,1);
    
    % find starts and stops of all reaches in each workspace
    iStart = find(diff(ind)>0);
    iStop  = find(diff(ind)<0);
    % A little Kluge to eleminate any partial trajectories at the beginning or
    % end of the file
    if iStart(1) > iStop(1)
        iStop = iStop(2:end);
    end

    if length(iStart) > length(iStop)
        iStart = iStart(1:length(iStop));
    end
    
    % discard some paths less than minimum length
    lMin = 3;
    keepers = true(size(iStart));
    for i = 1:length(keepers)
        snip = bdf_new.pos(iStart(i):iStop(i), 2:3);

        % Reject paths that are too short
        steps = diff(snip);
        len = sum(sqrt(steps(:,1).^2+steps(:,2).^2));
        keepers(i) = keepers(i) & len > lMin;
    end
    
    % Dump all the rejected trajectories
    iStart = iStart(keepers);
    iStop = iStop(keepers);
    
    % compile new fields for bdf_new
    fr = zeros(length(iStart),length(unit_list(bdf)));
    new_pos = [];
    new_vel = [];
    new_acc = [];
    new_force = [];
    new_good_flag = [];
    for i=1:length(iStart)
        new_pos = [new_pos;bdf.pos(iStart(i):iStop(i),:)];
        new_vel = [new_vel;bdf.vel(iStart(i):iStop(i),:)];
        new_acc = [new_acc;bdf.acc(iStart(i):iStop(i),:)];
        if(isfield(bdf,'force'))
            new_force = [new_force;bdf.force(iStart(i):iStop(i),:)];
        end
        if(isfield(bdf,'good_kin_data'))
            new_good_flag = [new_good_flag;bdf.good_kin_data(iStart(i):iStop(i),:)];
        end
    end
    bdf_new.pos = new_pos;
    bdf_new.vel = new_vel;
    bdf_new.acc = new_acc;
    if(isfield(bdf,'force'))
        bdf_new.force = new_force;
    end
    if(isfield(bdf,'good_kin_data'))
        bdf_new.good_kin_data = new_good_flag;
    end
    
    % get new spikes
    for uid = 1:length(bdf.units)
        spikes = [];
        s = bdf.units(uid).ts;
        for i=1:length(iStart)
            spikes = [spikes;s(s < t(iStop(i)) & s > t(iStart(i)))];
        end
        bdf_new.units(uid).ts = spikes;
    end % foreach unit
end