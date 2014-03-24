function trimBinnedData(root_dirs,tt_dir,use_array,doFiles,epochs,mtInds,binSize,rewriteFiles)
% makes a new binned data structure that is leaner and meaner
%   ie, reduces it to only parts relevant to the movement
%
% mtInds: movement table indices (ie [2 6])
%   [ target angle, on_time, go cue, move_time, peak_time, end_time]

if nargin < 7
    rewriteFiles = false;
end

for iFile = 1:size(doFiles,1)
    root_dir = root_dirs{strcmpi(root_dirs(:,1),doFiles{iFile,1}),2};
    
    y = doFiles{iFile,2}(1:4);
    m = doFiles{iFile,2}(6:7);
    d = doFiles{iFile,2}(9:10);
    
    for iEpoch = 1:length(epochs)
        bin_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '.mat']);
        out_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '_trim.mat']);
        tt_file = fullfile(tt_dir,doFiles{iFile,1},doFiles{iFile,2},[doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' doFiles{iFile,2} '.mat']);
        
        
        if ~exist(out_file,'file') || rewriteFiles
            disp('Building target angle vectors');
            load(bin_file);
            binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
            t = binnedData.timeframe;
            pos = binnedData.cursorposbin;
            vel = binnedData.velocbin;
            neural = binnedData.spikeratedata;
            
            % identify the beginning and end times of all movements
            % load the trial table
            
            load(tt_file,'trial_table');
            
            % it's going to be quite different for rt and co but this is already
            % implemented in my movement table function
            % [ target angle, on_time, go cue, move_time, peak_time, end_time, ]
            [mt,centers] = getMovementTable(trial_table,doFiles{iFile,4});
            
            allAngs = zeros(size(t,1),1);
            allAngs = [];
            allNeural = [];
            allVelocity = [];
            allPosition = [];
            for iMove = 1:size(centers,1)
                tstart = mt(iMove,mtInds(1));
                tend = mt(iMove,mtInds(2));
                
                inds = t >= tstart & t < tend;
                angs = atan2(centers(iMove,2)-pos(inds,2),centers(iMove,1)-pos(inds,1))+pi;
                
                allNeural = [allNeural; neural(inds,:)];
                allAngs = [allAngs; angs];
                allPosition = [allPosition; pos(inds,:)];
                allVelocity = [allVelocity; vel(inds,:)];
                
            end
            
            binnedData.spikeratedata = allNeural;
            binnedData.timeframe = binSize.*(1:length(allAngs))';
            binnedData.targetanglebin = allAngs;
            binnedData.velocbin = allVelocity;
            binnedData.cursorposbin = allPosition;
            binnedData.targetanglelabels = 'targ_angle';
            
            save(out_file,'binnedData');
            clear binsize t pos tt_file binnedData mt centers angs allAngs inds tstart tend binsize bin_file out_file tt_file;
        end
    end
end
disp('Done.');