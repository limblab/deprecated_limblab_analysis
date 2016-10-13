function BDF_FileNames = convertBatch2BDF(varargin)
    
    if nargin == 0
        [CB_FileNames, CB_PathName] = uigetfile( {'*.nev'},...
                                               'Open Cerebus Data File(s)', 'MultiSelect','on' );
        if ~CB_PathName
            disp('User Action Cancelled');
            BDF_FileNames = {};
            return;
        end
        
        %Save directory:
        savePath = uigetdir([CB_PathName filesep '..' filesep '..'],'Select a Destination Directory for BDF Files');
        if ~savePath
            disp('User Action Cancelled');
            BDF_FileNames = {};
            return;
        end
        
    elseif nargin == 3
        CB_FileNames = varargin{1};
        CB_PathName = varargin{2};
        savePath = varargin{3};
    else
       disp('Wrong Number of argument in call to ''convertBatch2BDF''');
       BDF_FileNames = {};
       return;
    end

    if iscell(CB_FileNames)
        numFiles = size(CB_FileNames,2);
    elseif ischar(CB_FileNames);
        numFiles = 1;
        CB_FileNames = {CB_FileNames};
    end        
    
    for i=1:numFiles
        if strcmp(CB_FileNames{i}(end-3:end),'.nev')
            BDF_FileNames(:,i) = strrep(CB_FileNames(:,i), '.nev', '_bdf.mat');
        else
            BDF_FileNames(:,i) = strrep(CB_FileNames(:,i), '.plx', '_bdf.mat');
        end
    end  

    for i=1:numFiles
        disp(sprintf('Converting %s to BDF structure...', CB_FileNames{:,i} ));
        out_struct = get_nev_mat_data([CB_PathName CB_FileNames{:,i}],'verbose','ignore_jumps');
        disp(sprintf('Saving BDF structure %s...',BDF_FileNames{:,i}));
        save([savePath filesep BDF_FileNames{:,i}], 'out_struct','-v7.3');
        disp('Done.');
    end
         
end