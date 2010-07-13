function BDF_FileNames = convertBatch2BDF(varargin)

    dataPath = 'C:\Monkey\Keedoo\';
    
    if nargin == 0
        [CB_FileNames, CB_PathName] = uigetfile( { [dataPath '\CerebusData\*.nev']},...
                                               'Open Cerebus Data File(s)', 'MultiSelect','on' );
        if ~PathName
            disp('User Action Cancelled');
            clear all;
            return;
        end
    elseif nargin == 3
        CB_FileNames = varargin{1};
        CB_PathName = varargin{2};
        dataPath = varargin{3};
    else
       disp('Wrong Number of argument in call to ''convertBatch2BDF''');
       return;
    end

    numFiles = size(CB_FileNames,2);
    
    for i=1:numFiles
        BDF_FileNames(:,i) = strrep(CB_FileNames(:,i), '.nev', '.mat');
    end  

    
    %Save directory:
    savePath = uigetdir([CB_PathName '\..\..'],'Select a Destination Directory');
    
    if ~savePath
        disp('User Action Cancelled');
        clear all;
        return;
    end
    
    for i=1:numFiles
        disp(sprintf('Converting %s to BDF structure...', CB_FileNames{:,i} ));
        out_struct = get_cerebus_data([CB_PathName CB_FileNames{:,i}],1);
        disp(sprintf('Saving BDF structure %s...',BDF_FileNames{:,i}));
        save([savePath '\' BDF_FileNames{:,i} ], 'out_struct');
        disp('Done.');
    end
         
end