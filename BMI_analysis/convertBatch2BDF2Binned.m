function convertBatch2BDF2Binned

%% Globals
    
    dataPath = 'D:\Monkey\';
    
%% Get Cerebus Data Files

%     CB_PathName = uigetdir( [dataPath 'CerebusData\'],...
%                                            'Select Cerebus Data Folder' );

    [CB_FileNames, CB_PathName] = uigetfile( { [dataPath '\*.nev']},...
                                               'Open Cerebus Data File', 'MultiSelect','on' );
                                                                                   
    if isequal(CB_PathName,0)
      %  User hit Cancel
      disp('User action cancelled');
      return;
    end

%% Get Paths

        BDFsavePath = uigetdir([CB_PathName '\..\..'],'Select a Destination Directory for BDF Files');
        if ~BDFsavePath
            disp('User Action Cancelled');
            return;
        end
    
        BINsavePath = uigetdir([CB_PathName '\..\..'],'Select a Destination Directory for Binned Files');
        if ~BINsavePath
            disp('User Action Cancelled');
            return;
        end
%% Get Data Binning Parameters

    [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate,NormData] = convertBDF2binnedGUI;

%% Convert Cerebus to BDF

    BDF_FileNames = convertBatch2BDF(CB_FileNames, CB_PathName, BDFsavePath);
    if isempty(BDF_FileNames)
        disp('Error converting Files to BDF');
        return;
    end

%% Convert BDF Structures to binned data

    convertBatch2Binned(BDF_FileNames, BDFsavePath, binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate,NormData,BINsavePath);
    
end