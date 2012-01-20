function BDF_META

% syntax BDF_META
%
% searches for all files on citadel/data in BDF-formatted .mat files
% (currently only Chewie, Mini).  Creates a digest consisting of:
% 
%       file name
%       the file's .meta field
%       age of decoder (brain control files only)
%       size of behavioral fields .pos, .vel, .acc
%       range information about .vel
%       type of control (hand/LFP/Spike)
%       mean hold time, calculated from each file's .words field
%       number of targets, calculated from each file's .words field
%       ordering information (1st file, last file, 1st hand control, etc).

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

META_struct=struct('filename','','meta',struct([]),'decoder_age',[], ...
    'vel_range',[],'control','','meanHoldTime',[],'numTargets',[]);

returns=[0 regexp(result,sprintf('\n'))];
for n=2:length(returns)
    candidatePath=result(returns(n-1)+1:returns(n)-1);
    fprintf(1,'file:\n')
    fprintf(1,'%s\n',candidatePath)
    fprintf(1,'file %d of %d\n',n-1,length(returns)-1)
    if exist(candidatePath,'file')==2        
        S=load(candidatePath);
        fname=fieldnames(S); 
        fname(cellfun(@isempty,regexpi(fname,'bdf|out_struct')))=[];
        bdf=S.(fname{1}); clear S
        
        META_struct(n).filename=bdf.meta.filename;
        META_struct(n).meta=bdf.meta;
        META_struct(n).vel_range=range(bdf.vel(:,2:3));
        
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
        META_struct(n).meanHoldTime=mean(bdf.words(reward_words,1)- ...
            bdf.words(reward_words-1,1));
        
        % take into account only the rewarded trials
        numTargets=zeros(length(reward_words));
        for k=1:length(reward_words)
            % the start of the current trial
            trial_start=find(bdf.words(1:reward_words(k),2)==18,1,'last');
            numTargets(k)=nnz(bdf.words(trial_start:reward_words(k),2)==49);
        end
        META_struct(n).numTargets=floor(mean(numTargets));
        
        % determine type of control.  If a species of brain control,
        % determine decoder age
        if (mean(range(bdf.vel(:,2:3))) > 10) && (size(bdf.pos,1)==size(bdf.acc,1))
            % hand control file
            META_struct(n).control='hand';
        else
            % unmodified brain control file (if the sizes are even but it fails
            % the ranges test), or modified brain control file (if it passes the
            % range test but the sizes are uneven).  In either case, track
            % down the type of decoder and the age of that decoder.
            if ismac
                fsep=filesep;
            else
                fsep=[filesep filesep]; % regexp chokes on backslash
            end
            pathToBR=regexprep(candidatePath,regexpi(candidatePath, ...
                ['(?<=',fsep,')','bdfs*(?=',fsep,')'],'match','once'), ...
                ['BrainReader logs',fsep,'online']);
            % just in case
            pathToBR(regexp(pathToBR,sprintf('\n')))='';
            if exist(pathToBR,'file')==2
                META_struct(n).control=decoderTypeFromLogFile(pathToBR,1);               
                META_struct(n).decoder_age=decoderDateFromLogFile(pathToBR,1);
            end
        end
        % save the output.  do it every iteration, so if there is
        % catastrophic failure, we can pick up where we left off (huh).
        currentPath=pwd;
        cd(startingPath)
        save('META_struct.mat','META_struct')
        cd(currentPath)
    end    
end



% leave META_struct.order for an outer-level function, one which loads up
% the output this function produces.  Reasoning: we want to examine across
% files to see which ones have the same datenum.  Doing that here is
% impractical, but once we have this database generated it becomes
% relatively trivial to do in an outer-level function.
% Hint: META_struct.order was intended to be the order within the day, i.e.
% 'first', 'last', or somewhere in between.  On second thought, probably
% should be a number.



