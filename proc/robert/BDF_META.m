function BDF_META(varargin)

% syntax BDF_META(META_struct)
%
% searches for all files on citadel/data in BDF-formatted .mat files
% (currently only Chewie, Mini).  Creates a digest consisting of:
%
%       file name
%       the file's .meta field
%       age of decoder (brain control files only)
%       range information about .vel
%       type of control (hand/LFP/Spike)
%       decoder age if brain control
%       mean hold time, calculated from each file's .words field
%       number of targets, calculated from each file's .words field
%
% currently, only implemented for RW behavior.  Should glide over others,
% providing file name and .meta field, and skipping over the other fields.
%
%       INPUTS:
%
%           META_struct (optional)  -   the output of a previously
%           completed run.  If supplied, the function will skip over any
%           files with the same names as those already represented.  It
%           will only process the new found files, append their results to
%           the existing results, and save a new copy of META_struct in the
%           directory where the function was run.

%   TODO:   -insert NaNs instead of empties?
%           -type of control, including whether LFP or spike or hand
%           -kinematics info from kinStruct by default.
%           -option to force-recalculate kinematics, from loaded BDF.

startingPath=pwd;

if ismac
    [status,result]=unix('find /Volumes/data/Chewie_8I2/BDFs -name "*.mat" -print');
    if status==0
        [status,resultTemp]=unix('find /Volumes/data/Mini_7H1/bdf -name "*.mat" -print');
        if status==0
            result=[result,resultTemp];
        else
            error(resultTemp)
        end
        clear resultTemp
    else
        error(result)
    end
else
    [status,result]=dos('cd /d Z:\Chewie_8I2\BDFs && dir *.mat* /s /b');
    if status==0
        [status,resultTemp]=dos('cd /d Z:\Mini_7H1\bdf && dir *.mat* /s /b');
        if status==0
            result=[result, resultTemp];
        else
            error(resultTemp)
        end
        clear resultTemp
    else
        error(result)
    end
end

if nargin
    META_struct=varargin{1};
else
    META_struct=struct('filename','','meta',struct([]),'decoder_age',[], ...
        'vel_range',[],'control','','meanHoldTime',[],'numTargets',[]);
end

returns=[0 regexp(result,sprintf('\n'))];
m=1;
for n=2:length(returns)
    candidatePath=result(returns(n-1)+1:returns(n)-1);
    fprintf(1,'file:\n')
    fprintf(1,'%s\n',candidatePath)
    fprintf(1,'file %d of %d\n',n-1,length(returns)-1)
    if exist(candidatePath,'file')==2
        [~,currentName,~]=fileparts(candidatePath);
        if nnz(strcmp(regexp({META_struct.filename}', ...
                '.*(?=\.nev|\.plx|\.mat)','match','once'),currentName))~=0
            % skip the loading, etc process if we have an existing
            % META_struct that was loaded in.
            fprintf(1,'%s found in %s passed as input.\n',currentName,inputname(1))
            m=m+1;
            continue
        end
        S=load(candidatePath);
        fname=fieldnames(S);
        fname(cellfun(@isempty,regexpi(fname,'bdf|out_struct')))=[];
        if ~isempty(fname)
            bdf=S.(fname{1}); clear S
            
            META_struct(m).filename=bdf.meta.filename;
            META_struct(m).path=candidatePath;
            META_struct(m).meta=bdf.meta;
            if isfield(bdf,'vel')
                velocityField=1;
                META_struct(m).vel_range=range(bdf.vel(:,2:3));
            else
                velocityField=0;
            end
            
            if velocityField
                % trim bdf.words to start and stop on appropriate words
                % make sure to start with the first complete trial in the recording
                beginFirstTrial=find(bdf.words(:,2)==18,1,'first');
                if beginFirstTrial > 1
                    bdf.words(1:beginFirstTrial-1,:)=[];
                end
                % make sure to end with the last complete trial in the recording
                % all of the following codes are valid trial-end codes: success (32),
                % abort (33), fail (34)
                endLastTrial=find(bdf.words(:,2)==32 | bdf.words(:,2)==33 | ...
                    bdf.words(:,2)==34,1,'last');
                if endLastTrial < size(bdf.words,1)
                    bdf.words(endLastTrial+1:end,:)=[];
                end
                % now, the items that depend on bdf.words
                reward_words=find(bdf.words(:,2)==32);
                if ~isempty(reward_words) && ~isempty(beginFirstTrial)
                    META_struct(m).meanHoldTime=mean(bdf.words(reward_words,1)- ...
                        bdf.words(reward_words-1,1));
                    
                    % take into account only the rewarded trials
                    numTargets=zeros(size(reward_words));
                    for k=1:length(reward_words)
                        % the start of the current trial
                        trial_start=find(bdf.words(1:reward_words(k),2)==18,1,'last');
                        numTargets(k)=nnz(bdf.words(trial_start:reward_words(k),2)==49);
                    end
                    META_struct(m).numTargets=floor(mean(numTargets));
                end
                
                % determine type of control.  If a species of brain control,
                % determine decoder age.  At this point, only works when there is a
                % velocity field.
                if (mean(range(bdf.vel(:,2:3))) > 10) && (size(bdf.pos,1)==size(bdf.acc,1))
                    % hand control file
                    META_struct(m).control='hand';
                else
                    % unmodified brain control file (if the sizes are even but it fails
                    % the ranges test), or modified brain control file (if it passes the
                    % range test but the sizes are uneven).  In either case, track
                    % down the type of decoder and the age of that decoder.
                    if ispc
                        fsep=[filesep filesep]; % regexp chokes on backslash
                    else
                        fsep=filesep;                        
                    end
                    pathToBR=regexprep(candidatePath,{regexpi(candidatePath, ...
                        ['(?<=',fsep,')','bdfs*(?=',fsep,')'],'match','once'),'\.mat'}, ...
                        {['BrainReader logs',fsep,'online'],'\.txt'});
                    % just in case
                    pathToBR(regexp(pathToBR,sprintf('\n')))='';
                    if exist(pathToBR,'file')==2
                        META_struct(m).control=decoderTypeFromLogFile(pathToBR);
                        try
                            META_struct(m).decoder_age=floor(datenum(bdf.meta.datetime))- ...
                                decoderDateFromLogFile(pathToBR,1);
                        end
                    end
                end
            end
            % save the output.  do it every iteration, so if there is
            % catastrophic failure, we can pick up where we left off (huh).
            currentPath=pwd;
            cd(startingPath)
            save('META_struct.mat','META_struct')
            cd(currentPath)
            m=m+1;
        end
    end
end
cd(startingPath)
fprintf(1,'\n\nMETA_struct.mat saved in %s\n',startingPath)


% leave META_struct.order for an outer-level function, one which loads up
% the output this function produces.  Reasoning: we want to examine across
% files to see which ones have the same datenum.  Doing that here is
% impractical, but once we have this database generated it becomes
% relatively trivial to do in an outer-level function.
% Hint: META_struct.order was intended to be the order within the day, i.e.
% 'first', 'last', or somewhere in between.  On second thought, probably
% should be a number.



