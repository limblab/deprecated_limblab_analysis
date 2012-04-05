function batch_analyzeLFPposition_offline_RDF(MATfiles,forceUpdate)

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
if nargin < 2
    forceUpdate=1;
end

for batchIndex=1:length(MATfiles)
    FileName=findBDFonCitadel(MATfiles{batchIndex},1);
    FileName(regexp(FileName,sprintf('\n')))=[];
    
    [~,name,~,~]=fileparts(FileName);
    % check to see if something with a similar name exists in the current
    % directory
    [status,result]=dos(['dir *',name,'* /s /b']);
    result(regexp(result,sprintf('\n')))=[];
    if forceUpdate || status~=0 || exist(result,'file')==0 
        fprintf(1,'analyzing %s...\n',name)
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
        analyze_LFPposition_offline_RDF(out_struct,'vel',name)
        save(sprintf('%spoly%d_%dfeats%s-decoder.mat',name,PolynomialOrder,nfeat,signal), ...
            'vaf','bestc','bestf','H','featMat','x','y','signal','numlags','wsz', ...
            'nfeat','PolynomialOrder','smoothfeats','binsize');
    else
        % look for the file in the current directory.  If found, skip this
        % file (so that we only end up doing the ones in the list that
        % weren't previously done.
        fprintf(1,'skipping, forceUpdate turned off, and found %s...\n',result)
    end
end

