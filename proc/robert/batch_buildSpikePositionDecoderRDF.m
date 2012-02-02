% this script operates on a folder that contains 1 or more .mat
% files containing FP and position data

% folder/file info
if exist('PathName','var')~=1
    PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
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
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'Spike_LFP.*(?<!poly.*)\.mat'))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
    disp('quitting...')
    return
end

%%
for batchIndex=1:length(MATfiles)
	FileName=MATfiles{batchIndex};
    
    % If this is going to be called from superBatch.m, we
    % can't rely on loading the files here and trusting that they'll exist
    % for LoadDataStruct.m which is called in convertBDF2binned.m, part of
    % buildSpikePositionDecoder.m (and which looks for a variable in the 
    % base workspace).  Therefore, must pass in the path, and 
    % suffer through loading twice, or else assignin here.
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
    assignin('base','out_struct',out_struct)
    % account for hand control files, which might have a brainReader log
    % recorded for testing purposes.
    if mean(range(out_struct.vel(:,2:3))) > 10
        % FUNCTION NOT A SCRIPT.  Trying to get smarter with time.
        buildSpikePositionDecoder(out_struct,0);
        close
        % no bestc/bestf for spike decoders, right?
%         % save bestc, bestf for reference with allFPsToPlot
%         if exist('allFPsToPlot.mat','file')==2
%             load('allFPsToPlot.mat','cutfp')
%             [~,nameNoExt,~,~]=fileparts(MATfiles{batchIndex});
%             cutfp(cellfun(@isempty,regexp({cutfp.name},nameNoExt))==0).bestc=bestc;
%             cutfp(cellfun(@isempty,regexp({cutfp.name},nameNoExt))==0).bestf=bestf;
%             save('allFPsToPlot.mat','cutfp')
%         end
    else
        fprintf(1,'skipping %s because it appears to be a brain control file.\n', ...
            MATfiles{batchIndex})
    end
end

