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

kinStruct=struct(name,'',decoder_age,[],'PL',[],'TT',[],'hitRate',[],'hitRate2',[]);
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
    % account for hand control files, which might have a brainReader log
    % recorded for testing purposes.
    if (exist('override','var')~=0 && override==1) || mean(range(out_struct.vel(:,2:3))) < 10 
        get_cursor_kinematics(out_struct);
    else
        fprintf(1,'skipping %s because it appears to be a hand control file.\n', ...
            MATfiles{batchIndex})
    end
    [kinStruct(batchIndex).PL,kinStruct(batchIndex).TT,kinStruct(batchIndex).hitRate, ...
        kinStruct(batchIndex).hitRate2]=kinematicsHandControl(out_struct);
    kinStruct(batchIndex).name=MATfiles{batchIndex};
    kinStruct(batchIndex).decoder_age=0;
    
    clear out_struct
end



