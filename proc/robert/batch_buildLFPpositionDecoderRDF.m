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
    MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'SpikeLFP.*(?<!poly.*)\.mat'))==0);
    if isempty(MATfiles)
        fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
        disp('quitting...')
        return
    end
end

%%
if exist('VAF_all','var')~=1
    VAF_all=struct('filename','','type','','vaf',[]);
    buildedVAF_all=1;
else
    buildedVAF_all=0;
end
for batchIndex=1:length(MATfiles)
	FileName=MATfiles{batchIndex};
    
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
    % account for hand control files, which might have a brainReader log
    % recorded for testing purposes.  the range of output velocities might
    % not be enough, if there is a transient in the position of the handle
    % halfway through the recording (e.g. it was bumped by the experimenter
    % accidentally).
    if mean(max(out_struct.vel(:,2:3))-min(out_struct.vel(:,2:3))) > 10 ...
            && (mean(max(out_struct.vel(:,2:3))-min(out_struct.vel(:,2:3))) < 300 || ...
            floor(mean(getNumTargets(out_struct)))>1)
        
        [vaf,H,bestf,bestc]=buildLFPpositionDecoderRDF(fullfile(PathName,FileName));
        [~,tempNameafkdlj,~]=FileParts(MATfiles{batchIndex});
        VAF_all=[VAF_all; struct('filename',tempNameafkdlj,'type','LFP','vaf',vaf)];
        clear tempNameafkdlj
        H_all{batchIndex}=H;
        bestf_all{batchIndex}=bestf;
        bestc_all{batchIndex}=bestc;
        close
        % save bestc, bestf for reference with allFPsToPlot
        if exist('allFPsToPlot.mat','file')==2
            load('allFPsToPlot.mat','cutfp')
            [~,nameNoExt,~]=FileParts(MATfiles{batchIndex});
            filePos=find(cellfun(@isempty,regexp({cutfp.name},nameNoExt))==0);
            if ~isempty(filePos)
                cutfp(filePos).bestc=bestc;
                cutfp(filePos).bestf=bestf;
            end
            save('allFPsToPlot.mat','cutfp')
        end
    else
        fprintf(1,'skipping %s because it appears to be a brain control file.\n', ...
            MATfiles{batchIndex})
    end
end
if buildedVAF_all
    VAF_all(1)=[];
end
