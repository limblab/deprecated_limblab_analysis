function convertBatch2BDF2Binned

%% Globals
    
    dataPath = 'C:\Monkey\Theo\Data\';
    
    addpath ../
    
%% Get Cerebus Data Files

%     CB_PathName = uigetdir( [dataPath 'CerebusData\'],...
%                                            'Select Cerebus Data Folder' );

    [CB_FileNames, CB_PathName] = uigetfile( { [dataPath '\CerebusData\*.nev']},...
                                               'Open Cerebus Data File', 'MultiSelect','on' );
                                                                                   
    if isequal(CB_PathName,0)
      %  User hit Cancel
      disp('User action cancelled');
      return;
    end
    
%% Get Data Binning Parameters

    [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate] = convertBDF2binnedGUI;
    
%% Convert Cerebus to BDF

    BDF_FileNames = convertBatch2BDF(CB_FileNames, CB_PathName, dataPath);

%% Convert BDF Structures to binned data

    convertBatch2Binned(BDF_FileNames, dataPath, binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate);
    
end