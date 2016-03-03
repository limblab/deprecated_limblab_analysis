function [bdf_DL,bdf_PM,bdf,times_DL,times_PM] = split_workspaces(folder, options)
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

[bdf_DL,times_DL] = extract_workspace(bdf,DL_ind);
[bdf_PM,times_PM] = extract_workspace(bdf,PM_ind);

end