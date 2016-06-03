function trimBinnedData(root_dirs,tt_dir,use_array,doFiles,epochs,itiCutoff,binSize,numLags,dupShift,rewriteFiles)
% makes a new binned data structure that is leaner and meaner
%   ie, reduces it to only parts relevant to the movement
%
% mtInds: movement table indices (ie [2 6])
%   [ target angle, on_time, go cue, move_time, peak_time, end_time]
doRotat = false;

xoffset = -3;
yoffset = 33;
minFR = 1; % minimum firing rate in Hz
tmax = 1;
tmin = 0.2;

if nargin < 8
    rewriteFiles = true;
end
numCutTrials = [];
numTrials = [];
for iFile = 1:size(doFiles,1)
    root_dir = root_dirs{strcmpi(root_dirs(:,1),doFiles{iFile,1}),2};
    
    y = doFiles{iFile,2}(1:4);
    m = doFiles{iFile,2}(6:7);
    d = doFiles{iFile,2}(9:10);
    
    if strcmpi(doFiles{iFile,4},'co')
        holdTime = 0.5;
    else
        holdTime = 0.1;
    end
    
    for iEpoch = 1:length(epochs)
        if strcmpi(epochs{iEpoch},'AD') && strcmpi(doFiles{iFile,3},'VR')
            rotAng = pi/6;
        else
            rotAng = 0;
        end
        
        bin_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '.mat']);
        out_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '_trim.mat']);
        tt_file = fullfile(tt_dir,doFiles{iFile,1},doFiles{iFile,2},[doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' doFiles{iFile,2} '.mat']);
        
        if ~exist(out_file,'file') || rewriteFiles
            disp('Building target angle vectors');
            load(bin_file);
            
            idx = mean(binnedData.spikeratedata,1) < minFR;
            binnedData.spikeratedata(:,idx) = [];
            binnedData.spikeguide(idx,:) = [];
            binnedData.neuronIDs(idx,:) = [];
            
            if dupShift
                % duplicate and shift
                binnedData.spikeratedata = DuplicateAndShift(binnedData.spikeratedata,numLags);
                % make a fake spike guide
                sg = char(zeros(size(binnedData.spikeratedata,2),7));
                nid = zeros(size(binnedData.spikeratedata,2),2);
                for i = 1:size(binnedData.spikeratedata,2)
                    if i < 10
                        sg(i,:) = ['ee00' num2str(i) 'u1'];
                    elseif i < 100
                        sg(i,:) = ['ee0' num2str(i) 'u1'];
                    else
                        sg(i,:) = ['ee' num2str(i) 'u1'];
                    end
                    nid(i,:) = [i,1];
                end
                binnedData.spikeguide = sg;
                binnedData.neuronIDs = nid;
            end
            
            t = binnedData.timeframe;
            pos = binnedData.cursorposbin;
            vel = binnedData.velocbin;
            neural = binnedData.spikeratedata;
            
            pos(:,1) = pos(:,1)+xoffset;
            pos(:,2) = pos(:,2)+yoffset;
            
            % identify the beginning and end times of all movements
            % load the trial table
            
            load(tt_file,'trial_table');
            
            % it's going to be quite different for rt and co but this is already
            % implemented in my movement table function
            % [ target angle, on_time, go cue, move_time, peak_time, end_time, ]
            [mt,centers] = getMovementTable(trial_table,doFiles{iFile,4});
            
            %             if doRotat
            %                 % Rotate target to be endpoint of hand
            %                 R = [cos(rotAng) -sin(rotAng); sin(rotAng) cos(rotAng)];
            %                 for j = 1:length(centers)
            %                     centers(j,:) = R*(centers(j,:)');
            %                 end
            %             end
            
            allAngs = [];
            allNeural = [];
            allPosition = [];
            allVelocity = [];
            
            % do first movement
            tdur = mt(1,6)-holdTime-mt(1,3);
            if  tdur <= tmax && tdur >= tmin
                tstart = mt(1,2);
                tend = mt(1,6);
                inds = t >= tstart & t < tend;
                % make target direction vector
                angs = atan2(centers(1,2)-pos(inds,2),centers(1,1)-pos(inds,1));
                cartAngs = [cos(angs), sin(angs)]; % get cartesian angles
                
                allAngs = [allAngs; cartAngs];
                allNeural = [allNeural; neural(inds,:)];
                allPosition = [allPosition; pos(inds,:)];
                allVelocity = [allVelocity; vel(inds,:)];
            end
            
            iti = zeros(1,size(centers,1)-1);
            count = 0;
            for iMove = 2:size(centers,1)
                % get inter-trial-interval
                iti(iMove-1) = mt(iMove,2)-mt(iMove-1,6);
                
                % exclude segments of data with long iter-trial interval
                if iti(iMove-1) < itiCutoff
                    count = count + 1;
                    
                    % first do return to center
                    tstart = mt(iMove-1,6);
                    tend = mt(iMove,2);
                    inds = t >= tstart & t < tend;
                    % rotate position into cursor coordinates
                    handPos = pos(inds,:);
                    if doRotat
                        cursPos = zeros(size(handPos));
                        R = [cos(rotAng) -sin(rotAng); sin(rotAng) cos(rotAng)];
                        for j = 1:length(handPos)
                            cursPos(j,:) = R*(handPos(j,:)');
                        end
                    else
                        cursPos=handPos;
                    end
                    
                    % make target direction vector
                    angs = atan2(centers(iMove,2)-cursPos(:,2),centers(iMove,1)-cursPos(:,1));
                    cartAngs = [cos(angs), sin(angs)]; % get cartesian angles
                    allAngs = [allAngs; cartAngs];
                    allNeural = [allNeural; neural(inds,:)];
                    allPosition = [allPosition; pos(inds,:)];
                    allVelocity = [allVelocity; vel(inds,:)];
                end
                
                tdur = mt(iMove,6)-holdTime-mt(iMove,3);
                
                if  tdur <= tmax && tdur >= tmin
                    % then do movement to outer target
                    tstart = mt(iMove,2);
                    tend = mt(iMove,6);
                    inds = t >= tstart & t < tend;
                    
                    
                    handPos = pos(inds,:);
                    if doRotat
                        % rotate position into cursor coordinates
                        cursPos = zeros(size(handPos));
                        R = [cos(rotAng) -sin(rotAng); sin(rotAng) cos(rotAng)];
                        for j = 1:length(handPos)
                            cursPos(j,:) = R*(handPos(j,:)');
                        end
                    else
                        cursPos=handPos;
                    end
                    
                    % make target direction vector
                    angs = atan2(centers(iMove,2)-cursPos(:,2),centers(iMove,1)-cursPos(:,1));
                    cartAngs = [cos(angs), sin(angs)]; % get cartesian angles
                    allAngs = [allAngs; cartAngs];
                    allNeural = [allNeural; neural(inds,:)];
                    allPosition = [allPosition; pos(inds,:)];
                    allVelocity = [allVelocity; vel(inds,:)];
                end
            end
            
            numCutTrials = [numCutTrials,count];
            numTrials = [numTrials,length(iti)];
            
            binnedData.spikeratedata = allNeural;
            binnedData.timeframe = binSize.*(1:length(allAngs))';
            binnedData.velocbin = allVelocity;
            binnedData.cursorposbin = allPosition;
            
            binnedData.targetanglebin = allAngs;
            binnedData.targetanglelabels = ['targ_dir_x';'targ_dir_y'];
            
            save(out_file,'binnedData');
            clear binsize t pos tt_file binnedData mt centers angs allAngs inds tstart tend binsize bin_file out_file tt_file;
        end
    end
    
    % get master spike guide for all epochs
    sg = cell(1,length(epochs));
    for iEpoch = 1:length(epochs)
        out_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '_trim.mat']);
        load(out_file);
        sg{iEpoch}=binnedData.spikeguide;
    end
    
    badUnits = checkUnitGuides(sg);
    
    % now, remove the badUnits from up above
    if ~isempty(badUnits)
        disp('Removing bad units...');
        for iEpoch = 1:length(epochs)
            out_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '_trim.mat']);
            load(out_file);
            [~,idx] = setdiff(binnedData.spikeguide,badUnits,'rows');
            binnedData.spikeratedata = binnedData.spikeratedata(:,idx);
            binnedData.spikeguide = binnedData.spikeguide(idx,:);
            binnedData.neuronIDs = binnedData.neuronIDs(idx,:);
            
            save(out_file,'binnedData');
        end
    end
    
end
if ~isnan( 100*sum(numCutTrials)/sum(numTrials) )
    disp(['Percentage of ITIs kept: ' num2str(100*sum(numCutTrials)/sum(numTrials))]);
end
disp('Done.');