% this script operates on a folder that contains 1 or more .mat
% files containing FP and position data

% folder/file info
if exist('PathName','var')~=1
    PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
end
if sum(double(PathName)==0)~=0
    disp('cancelled')
    clear PathName
    return
end
% PathName=pwd;
if exist(PathName,'dir')~=7
    disp('folder not valid.  aborting...')
    return
end
cd(PathName)
Files=dir(PathName);
Files(1:2)=[];
FileNames={Files.name};
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'Spike_LFP.*(?<!poly.*|-spike.*)\.mat'))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
    disp('quitting...')
    return
end

kinStruct=struct('name','','decoder_age',[],'PL',[],'TT',[],'hitRate',[],'hitRate2',[]);
%%
for batchIndex=1:length(MATfiles)
    fprintf(1,'getting cursor kinematics for %s.\n',MATfiles{batchIndex})
    S=load(MATfiles{batchIndex});
    if isfield(S,'bdf')
        out_struct=S.bdf;
    elseif isfield(S,'out_struct')
        out_struct=S.out_struct;
    else
        % account for decoder files
        fprintf(1,'skipping %s because it does not have a BDF-struct.\n', ...
            MATfiles{batchIndex})
        continue
    end
    clear S
    
    % account for brain control files WITH handle.  A tiny minority,
    % but needs addressed.  Use number of targets.
    % first, always must account for bad starts/ends.
    % make sure to start with the first complete trial in the recording
    beginFirstTrial=find(out_struct.words(:,2)==18,1,'first');
    if beginFirstTrial > 1
        out_struct.words(1:beginFirstTrial-1,:)=[];
    end
    % make sure to end with the last complete trial in the recording
    % all of the following codes are valid trial-end codes: success (32),
    % abort (33), fail (34)
    endLastTrial=find(out_struct.words(:,2)==32 | out_struct.words(:,2)==33 | out_struct.words(:,2)==34,1,'last');
    if endLastTrial < size(out_struct.words,1)
        out_struct.words(endLastTrial+1:end,:)=[];
    end
    rewarded_trials=find(out_struct.words(:,2)==32);
    start_trial=zeros(size(rewarded_trials)); numTargets=start_trial;
    for trial_index=1:length(rewarded_trials)
        start_trial(trial_index)= ...
            find(out_struct.words(1:rewarded_trials(trial_index),2)==18,1,'last');
        numTargets(trial_index)=nnz(out_struct.words(start_trial(trial_index): ...
            rewarded_trials(trial_index),2)==49);
    end

    if (exist('override','var')~=0 && override==1) || mean(range(out_struct.vel(:,2:3))) < 10
        % we're in brain control country.  Savor the flavor.
        get_cursor_kinematics(out_struct);              % 1 to store in the remote directory
        out_struct=get_cursor_kinematics(out_struct);   % 1 for the upcoming kinematics calculation
        if isfield(out_struct.meta,'decoder_age')
            kinStruct(batchIndex).decoder_age=out_struct.meta.decoder_age;
            kinStruct(batchIndex).PL=out_struct.path_length;
            kinStruct(batchIndex).TT=out_struct.time_to_target;
            kinStruct(batchIndex).hitRate=out_struct.hitRate;
            kinStruct(batchIndex).hitRate2=out_struct.hitRate2;
        else
            % this happens when get_cursor_kinematices was unable to modify
            % the BDF, (e.g., there was no BR log file)
            kinStruct(batchIndex).decoder_age=NaN;
        end
    else % if the mean range of velocities is not low, we're either in hand
         % control, or brain control with handle, or the file has been run
         % previously.
        if ~isfield(out_struct.meta,'decoder_age') % file was not run previously...
            if floor(mean(numTargets)) < 3  % then, brain control with handle.
                get_cursor_kinematics(out_struct);              % 1 to store in the remote directory
                out_struct=get_cursor_kinematics(out_struct);   % 1 for the upcoming kinematics calculation
                if isfield(out_struct.meta,'decoder_age')
                    kinStruct(batchIndex).decoder_age=out_struct.meta.decoder_age;
                    kinStruct(batchIndex).PL=out_struct.path_length;
                    kinStruct(batchIndex).TT=out_struct.time_to_target;
                    kinStruct(batchIndex).hitRate=out_struct.hitRate;
                    kinStruct(batchIndex).hitRate2=out_struct.hitRate2;
                else
                    % this happens when get_cursor_kinematices was unable to modify
                    % the BDF, (e.g., there was no BR log file)
                    kinStruct(batchIndex).decoder_age=NaN;
                end
            else
                fprintf(1,'%s appears to be a hand control file.\n',MATfiles{batchIndex})
                fprintf(1,'calculating handle kinematics instead...\n')
                kinStruct(batchIndex).decoder_age=NaN; % because hand control!
                opts=struct('version',2);
                if floor(datenum(out_struct.meta.datetime)) <= datenum('09-12-2011')
                    opts.version=1; opts.hold_time=0.1;
                end
                [kinStruct(batchIndex).PL,kinStruct(batchIndex).TT,kinStruct(batchIndex).hitRate, ...
                    kinStruct(batchIndex).hitRate2]=kinematicsHandControl(out_struct,opts);
            end
        else
            % brain control file that was
            % run previously and now has pos/vel data.  Happens during
            % re-runs of folders.  Don't want to replace good data with
            % bad.  Also avoids having to re-save, by not re-running
            % get_cursor_kinematics.m
            fprintf(1,'%s appears to be a re-run.\n',MATfiles{batchIndex})
            fprintf(1,'copying parameter values from bdf to kinStruct.mat.\n')
            kinStruct(batchIndex).decoder_age=out_struct.meta.decoder_age;
            kinStruct(batchIndex).PL=out_struct.path_length;
            kinStruct(batchIndex).TT=out_struct.time_to_target;
            kinStruct(batchIndex).hitRate=out_struct.hitRate;
            kinStruct(batchIndex).hitRate2=out_struct.hitRate2;
        end
    end
    kinStruct(batchIndex).name=MATfiles{batchIndex};
    clear out_struct decoder_age beginFirstTrial endLastTrial numTargets opts
    clear rewarded_trials start_trial trial_index
end

save(fullfile(PathName,'kinStruct.mat'),'kinStruct')
% make sure to save a copy in FilterFiles 
if ~isempty(regexp(pwd,'bdf|BDFs','once'))
    % pwd is on citadel, save a copy in FilterFiles
    if exist(regexprep(pwd,'bdf|BDFs','FilterFiles'),'dir')==7
        save(fullfile(regexprep(pwd,'bdf|BDFs','FilterFiles'),'kinStruct.mat'),'kinStruct')
    else
        save(fullfile(regexprep(pwd,'bdf|BDFs','Filter files'),'kinStruct.mat'),'kinStruct')
    end
end


