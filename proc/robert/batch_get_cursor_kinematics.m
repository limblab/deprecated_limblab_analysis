% this script operates on a folder that contains 1 or more .mat
% files containing FP and position data

% folder/file info
if exist('PathName','var')~=1
    PathName = uigetdir('E:\monkey data\','select folder with data files');
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
% get rid of other types of files that don't have the standard filename
% pattern.
MATfiles(cellfun(@isempty,regexp(MATfiles,'(Chewie|Mini|Jaco)_Spike_(LFP|LFPL)_[0-9]+\.mat')))=[];
if isempty(MATfiles)
    fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
    disp('quitting...')
    return
end

kinStruct=struct('name','','decoder_age',[],'PL',[],'TT',[],'hitRate',[],'hitRate2',[],...
    'control','','num_targets',[],'duration',0,'speedProfile',[],'pathReversals',[],...
    'LFP_vaf',[],'Spike_vaf',[],'trialTS',[]);
%%
for batchIndex=1:length(MATfiles)
    fprintf(1,'getting cursor kinematics for %s.\n',MATfiles{batchIndex})
    if exist('out_struct','var')~=1 || ...
            ~strcmp(regexprep(out_struct.meta.filename,'\.plx','.mat'),MATfiles{batchIndex})
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
    end
    % for CO recordings, the logic to determind HC from BC is not reliable.  
    
    
    
    
    
    
    
    % account for brain control files WITH handle.  A tiny minority,
    % but needs addressed.  Use number of targets.
    numTargets=getNumTargets(out_struct);
    kinStruct(batchIndex).num_targets=floor(mean(numTargets));
    % regardless of what else happens, we'll always have duration.
    kinStruct(batchIndex).duration=out_struct.meta.duration;

    % don't use the range function because it is terrible.  relies on some
    % damn license that's always crapping out because of too many
    % concurrent users.
    
    % once we started doing CO tasks, the number of targets ceased to be
    % meaningful
    if (exist('override','var')~=0 && override==1) || ...
            (mean(max(out_struct.vel(:,2:3))-min(out_struct.vel(:,2:3))) < 10) || ...
            (mean(max(out_struct.vel(:,2:3))-min(out_struct.vel(:,2:3))) > 300)
        % we're in brain control country.  Savor the flavor.
        get_cursor_kinematics(out_struct);              % 1 to store in the remote directory
        out_struct=get_cursor_kinematics(out_struct);   % 1 for the upcoming kinematics calculation
        % need a function (or other clever way) to determine whether LFP
        % or spike control.  Most obvious is by looking at the decoder
        % line, which probably means putting it in get_cursor_kinematics
        if isfield(out_struct.meta,'decoder_age')
            kinStruct(batchIndex).decoder_age=out_struct.meta.decoder_age;
            kinStruct(batchIndex).PL=out_struct.kin.path_length;
            kinStruct(batchIndex).TT=out_struct.kin.time_to_target;
            kinStruct(batchIndex).hitRate=out_struct.kin.hitRate;
            kinStruct(batchIndex).hitRate2=out_struct.kin.hitRate2;
            kinStruct(batchIndex).control=out_struct.meta.control;
            kinStruct(batchIndex).speedProfile=out_struct.kin.speedProfile;
            kinStruct(batchIndex).pathReversals=out_struct.kin.pathReversals;
            kinStruct(batchIndex).trialTS=out_struct.kin.trialTS;
            kinStruct(batchIndex).interTargetDistance=out_struct.kin.intertarget_distance;
            kinStruct(batchIndex).slidingAccuracy=out_struct.kin.slidingAccuracy;
            kinStruct(batchIndex).slidingTime=out_struct.kin.slidingTime;
            % Fitts' Law calculations.  un-normalized time to target...
            unTT=kinStruct(batchIndex).TT./kinStruct(batchIndex).interTargetDistance;
            % and Index of Difficulty
            IndDiff=log2(kinStruct(batchIndex).interTargetDistance/4 + 1);
            % coefficients of the fit will be: ab=polyfit(IndDiff,unTT,1);
        else
            % this happens when get_cursor_kinematices was unable to modify
            % the BDF, (e.g., there was no BR log file).  Can't tell
            % decoder_age, and shouldn't assign an ID as to hand or brain
            % control because we don't know.
            kinStruct(batchIndex).decoder_age=NaN;
            kinStruct(batchIndex).control='';
        end
    else % if the mean range of velocities is not low, we're either in hand
         % control, or brain control with handle, or the file has been run
         % previously.
        if ~isfield(out_struct.meta,'decoder_age') % file was not run previously...
            if ((floor(mean(numTargets)) < 3) && ... % brain control with handle.
                    (mean(max(out_struct.vel(:,2:3))-min(out_struct.vel(:,2:3))) < 300) && ...
                    nnz(out_struct.words(:,2)==18))
                % this if statement should be functional, but it is not
                % complete.  It doesn't account for CO brain control
                % w/handle.  Right now that doesn't occur so it works, but
                % it will need updated in a future release.
                get_cursor_kinematics(out_struct);              % run once, to store in the remote directory
                out_struct=get_cursor_kinematics(out_struct);   % run again, for the upcoming kinematics calculation
                % make a stab at perfectly silent failure
                try
                    kinStruct(batchIndex).control=out_struct.meta.control;
                catch
                    % still need the name
                    kinStruct(batchIndex).name=MATfiles{batchIndex};
                    continue
                end
                if isfield(out_struct.meta,'decoder_age')
                    kinStruct(batchIndex).decoder_age=out_struct.meta.decoder_age;
                    kinStruct(batchIndex).PL=out_struct.kin.path_length;
                    kinStruct(batchIndex).TT=out_struct.kin.time_to_target;
                    kinStruct(batchIndex).hitRate=out_struct.kin.hitRate;
                    kinStruct(batchIndex).hitRate2=out_struct.kin.hitRate2;
                    kinStruct(batchIndex).speedProfile=out_struct.kin.speedProfile;
                    kinStruct(batchIndex).pathReversals=out_struct.kin.pathReversals;
                    kinStruct(batchIndex).trialTS=out_struct.kin.trialTS;
                    kinStruct(batchIndex).interTargetDistance= ...
                        out_struct.kin.intertarget_distance;
                    kinStruct(batchIndex).slidingAccuracy=out_struct.kin.slidingAccuracy;
                    kinStruct(batchIndex).slidingTime=out_struct.kin.slidingTime;
                else
                    % this happens when get_cursor_kinematices was unable to modify
                    % the BDF, (e.g., there was no BR log file)
                    kinStruct(batchIndex).decoder_age=NaN;
                end
            else
                fprintf(1,'%s appears to be a hand control file.\n',MATfiles{batchIndex})
                fprintf(1,'calculating handle kinematics instead...\n')
                kinStruct(batchIndex).decoder_age=NaN; % because hand control!
                kinStruct(batchIndex).control='hand';
                if ~exist('opts','var')
                    opts=struct('version',2,'includeFails',0);                    
                end
                if floor(datenum(out_struct.meta.datetime)) <= datenum('09-12-2011')
                    opts.version=1; opts.hold_time=0.1;
                end                
                [kinStruct(batchIndex).PL,kinStruct(batchIndex).TT,kinStruct(batchIndex).hitRate, ...
                    kinStruct(batchIndex).hitRate2,kinStruct(batchIndex).speedProfile, ...
                    kinStruct(batchIndex).pathReversals,kinStruct(batchIndex).trialTS, ...
                    kinStruct(batchIndex).interTargetDistance,kinStruct(batchIndex).slidingAccuracy, ...
                    kinStruct(batchIndex).slidingTime]=kinematicsHandControl2(out_struct,opts);
                % if we're running inside superBatch.m, then VAF_all should
                % exist.  If not, create it.  This will override any stored
                % .LFP_vaf or .Spike_vaf values that might have been
                % created at superBatch time, when
                % batch_get_cursor_kinematics is re-run.  That's why we
                % need an offline way, such as seekVAFinDecoderLog, but
                % something that isn't so ridiculously time-consuming.
                if exist('VAF_all','var')~=1
                    % VAF_all=seekVAFinDecoderLog(MATfiles{batchIndex});
                    disp('skipping VAF seeking operation because it takes too long')
                else
                    kinStruct(batchIndex).LFP_vaf=VAF_all(find(cellfun(@isempty,regexp({VAF_all.filename},...
                        regexprep(MATfiles{batchIndex},'\.mat','')))==0 & ...
                        strcmp({VAF_all.type},'LFP'),1,'first')).vaf;
                    kinStruct(batchIndex).Spike_vaf=VAF_all(find(cellfun(@isempty,regexp({VAF_all.filename},...
                        regexprep(MATfiles{batchIndex},'\.mat','')))==0 & ...
                        strcmp({VAF_all.type},'Spike'),1,'first')).vaf;
                end
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
            kinStruct(batchIndex).PL=out_struct.kin.path_length;
            kinStruct(batchIndex).TT=out_struct.kin.time_to_target;
            kinStruct(batchIndex).hitRate=out_struct.kin.hitRate;
            kinStruct(batchIndex).hitRate2=out_struct.kin.hitRate2;
            kinStruct(batchIndex).control=out_struct.meta.control;
            kinStruct(batchIndex).speedProfile=out_struct.kin.speedProfile;
            kinStruct(batchIndex).pathReversals=out_struct.kin.pathReversals;
            kinStruct(batchIndex).trialTS=out_struct.kin.trialTS;
            kinStruct(batchIndex).interTargetDistance=out_struct.kin.intertarget_distance;
            kinStruct(batchIndex).slidingAccuracy=out_struct.kin.slidingAccuracy;
            kinStruct(batchIndex).slidingTime=out_struct.kin.slidingTime;
        end
    end
    kinStruct(batchIndex).name=MATfiles{batchIndex};
    clear out_struct decoder_age beginFirstTrial endLastTrial numTargets %opts
    clear rewarded_trials start_trial trial_index
end



fprintf(1,['%s no longer saves a copy of kinStruct.mat.\nIt ',...
    'is now the responsibility of the calling script/function.\n'],mfilename)
return

save(fullfile(PathName,'kinStruct.mat'),'kinStruct')
% make sure to save a copy in FilterFiles, if we're operating on the
% network.
if ~isempty(regexp(pwd,'bdf|BDFs','once'))
    % pwd is on citadel, save a copy in FilterFiles
    if exist(regexprep(pwd,'bdf|BDFs','FilterFiles'),'dir')==7
        save(fullfile(regexprep(pwd,'bdf|BDFs','FilterFiles'),'kinStruct.mat'),'kinStruct')
    else
        save(fullfile(regexprep(pwd,'bdf|BDFs','Filter files'),'kinStruct.mat'),'kinStruct')
    end
end


