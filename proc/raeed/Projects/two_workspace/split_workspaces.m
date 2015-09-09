function [bdf_DL,bdf_PM,bdf] = split_workspaces(folder, options)
% SPLIT_WORKSPACES Splits a Random Walk dataset into a
% distal-lateral workspace and a proximal-medial workspace to compare the
% tunings in the two.

if(~isfield(options,'bdf'))
    if(folder(end)~=filesep)
        folder = [folder filesep];
    end
    bdf = get_nev_mat_data([folder options.prefix],options.labnum);
else
    bdf = options.bdf;
end
bdf_DL = bdf;
bdf_PM = bdf;

pos = bdf.pos;

DL_ind = pos(:,2)<mean(pos(:,2)) & pos(:,3)>mean(pos(:,3));
PM_ind = pos(:,2)>mean(pos(:,2)) & pos(:,3)<mean(pos(:,3));

% find starts and stops of all reaches in each workspace
% save only those reach kinematics into new, copied bdfs
% For each unit, for each DL reach and PM reach, split up spikes into
% different bdfs