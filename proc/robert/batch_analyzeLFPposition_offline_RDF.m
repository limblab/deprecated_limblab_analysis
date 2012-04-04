function batch_analyzeLFPposition_offline_RDF(MATfiles)

if ~nargin
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
end

%%
for batchIndex=1:length(MATfiles)
    FileName=findBDFonCitadel(MATfiles{batchIndex},1);
    
    S=load(FileName);
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
    % account for hand control files that might have a brainReader log
    % recorded for testing purposes.
    if mean(range(out_struct.vel(:,2:3))) > 10
        buildLFPpositionDecoderRDF
        % assign/save variables from this workspace.
    else
        fprintf(1,'skipping %s because it appears to be a brain control file.\n', ...
            MATfiles{batchIndex})
    end
end

