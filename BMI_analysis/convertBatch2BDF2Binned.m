function convertBatch2BDF2Binned

%% Globals
    
    dataPath = 'C:\Monkey\Theo\Data\';
    
    addpath ../
    
%% Get Cerebus Data Files

    CB_PathName = uigetdir( [dataPath 'CerebusData\'],...
                                           'Select Cerebus Data Folder' );
    if isequal(CB_PathName,0)
      %  User hit Cancel
      disp('User action cancelled');
      return;
    else
        CB_FileNames = ls( [CB_PathName '\*.nev']);
    end
    
    for i=1:size(CB_FileNames,1)
        BDF_FileNames(i,:) = strrep(CB_FileNames(i,:), '.nev', '.mat');
    end    

%% Get Data Binning Parameters

    [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate] = convertBDF2binnedGUI;
    
%% Convert Cerebus to BDF

    cd ../bdf;
    for i=1:size(CB_FileNames,1)
        disp(sprintf('Converting %s to BDF structure...', CB_FileNames(i,:) ));
        out_struct = get_cerebus_data([CB_PathName '\' CB_FileNames(i,:)],1);
        disp(sprintf('Saving BDF structure %s...',BDF_FileNames(i,:)));
        save([dataPath 'BDFStructs\' BDF_FileNames(i,:) ], 'out_struct');
        disp('Done.');
    end
      
    cd ../BMI_analysis;
    clear out_struct;

%% Convert BDF Structures to binned data

    Bin_FileNames = BDF_FileNames;
    
    for i=1:size(BDF_FileNames,1)
        disp(sprintf('Binning %s structure...', BDF_FileNames(i,:) ));
        binnedData = convertBDF2binned([dataPath 'BDFStructs\' BDF_FileNames(i,:)],binsize,starttime,stoptime,hpfreq,lpfreq,MinFiringRate);
        disp(sprintf('Saving binned data file %s...',Bin_FileNames(i,:)));
        save([dataPath 'BinnedData\' Bin_FileNames(i,:) ], 'binnedData');
        disp('Done.');
    end
    
end