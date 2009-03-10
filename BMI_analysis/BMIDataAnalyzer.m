function BMIDataAnalyzer()
%GUI that process and plot data for Neural FES systems
%
%First, the API asks you to provide the base folder of the data to
%analyse. This folder (refered to as dataPath below, must contain the
%following subfolders (with exact names) :
%
%  dataPath +
%           |
%           - BDFStructs\   subfolder for storing BDF structure files
%           |
%           - BinnedData\   subfolder for storing binned spike and emg
%           |               data structures
%           - CerebusData\  subfolder for storing .nev and .nsx data
%           |               from Cerebus
%           - NeuronIDfiles\for future use, to store files specifying
%           |               units to use for model building
%           - OLPreds\      for storing off-line EMG predictions
%           |
%           - RTPreds\      for storing real-time EMG predictions
%           |
%           - SavedFilters\ for storing the models
%
% Notes:
% 
%   (1)    RTPreds are provided by NLMS in .txt format. Before they can be of any use for
%   this application, they must be saved as .mat file and saved in a
%   variable named RTPredData. Also the ts have to be converted to
%   seconds.
%       e.g. - clic & drag .txt file in matlab workspace window
%            - set number of header lines to 9 to actually see the data
%               in the preview window. ->finish
%            >> RTPredData = data;
%            >> RTPredData(:,1) = data(:,1)/30000; % convert ts to seconds (for sample rate of 30kHz)
%            - save the variable as a .mat file in the RTPreds\ folder.
%
%
%   (2)     Models saved in SavedFilters with this application have yet
%   to be modified before they cand be used by NLMS. This application
%   saves a structure whereas NLMS (as of 03-10-09) needs to be provided with a .mat
%   file with variables (this is supposed to change in the future.
%       e.g. >> load([path 'Theo_03-06-09_001_filter.mat']);
%            >> H = filter.H;
%            >> P = filter.P;
%            >> neuronIDs = filter.neuronIDs;
%            - save H, P and neuronIDs in a .mat file to be loaded with NLMS
%
%   (3)     The LOAD buttons subroutines don't actually load the files.
%   They just provide the user with a mean of specifying file paths and
%   names that (s)he wants to process. The data files are loaded each
%   time an action on them is required. That slows all the processes a
%   little, but I thought Matlab would run out of memory less often
%   this way
%
%   (4) Bugs:
%       -Out of Memory error occurs when binning data files. In my
%           case, I found that with 12 EMGS and >100 spike units, I can
%           bin files up to 23 mins long, but Matlab crashes for longer
%           files.
%
%       -Segmentation Fault error occurs from time to time, especially
%           when binning data right after having converted a .nev file
%           to BDF. Again, this is a problem with Matlab, not my code.
%   
%       + For both these error and for most others, restarting Matlab
%       will solve the problems.
%
% $Id: BMIDataAnalyzer.m 1 2009-03-10 11:58:46Z chris $
    
    
    
%% Globals
    
    dataPath = 'C:\Monkey\Theo\Data\';
    dataPath = uigetdir(dataPath, 'Please choose the base data directory');
    
    addpath ../
    
    %Global Variables
    CB_FileName = 0;
    CB_FullFileName = 0;
    BDF_FileName = 0;
    BDF_FullFileName = 0;
    Bin_FileName = 0;
    Bin_FullFileName = 0;
    Filt_FileName = 0;
    Filt_FullFileName = 0;
    OLPred_FileName = 0;
    OLPred_FullFileName = 0;
    RTPred_FileName = 0;
    RTPred_FullFileName = 0;
       
     
%% Creating UI

    UI = figure('Units','normalized','Position',[.33 .125 .34 .75]);
    set(UI,'Name','BMI Data Analyzer');
    set(UI,'NumberTitle','off');
    
    %vertical pannel position
    PanelsPos = linspace(0.025,0.975-0.13,7);
    
    CB_DataPanel = uipanel('Parent',UI,'Title','CerebusData','Position',[0.015 PanelsPos(7) .97 .13]);
    BDF_Panel = uipanel('Parent',UI,'Title','BDF Struct','Position', [0.015 PanelsPos(6) 0.97 .13]);
    Bin_Panel =uipanel('Parent',UI,'Title','BinnedData','Position',[0.015 PanelsPos(5) 0.97 .13]);
    Filt_Panel =uipanel('Parent',UI,'Title','Filter','Position',[0.015 PanelsPos(4) 0.97 .13]);
    OLPred_Panel =uipanel('Parent',UI,'Title','Offline EMG Predictions','Position',[0.015 PanelsPos(3) 0.97 .13]);
    RTPred_Panel = uipanel('Parent',UI,'Title','Real-Time EMG Predictions','Position',[0.015 PanelsPos(2) 0.97 .13]);
    SC_Panel =uipanel('Parent',UI,'Title','Stimulator PW Commands','Position',[0.015 PanelsPos(1) 0.97 .13]);
    

%% Cerebus Panel

    %Buttons
    CB_LoadButton = uicontrol('Parent', CB_DataPanel, 'String', 'LOAD','Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@CB_LoadButton_Callback,'Enable','on');

    CB_ConvertButton = uicontrol('Parent', CB_DataPanel, 'String', 'Convert to BDF','Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@CB_ConvertButton_Callback,'Enable','off');
                        
    %Callbacks
    function CB_LoadButton_Callback(obj,event)
       
        [CB_FileName, PathName] = uigetfile([dataPath '\CerebusData\*.nev'], 'Open Cerebus Data File');
        
        if isequal(CB_FileName,0) || isequal(PathName,0)
          %  CB_FileName = 'User Cancelled File Loading';
          disp('User action cancelled');
        else
            CB_FullFileName = fullfile(PathName, CB_FileName);
            set(CB_ConvertButton,'Enable','on');
            
            CB_FileLabel =  uicontrol('Parent',CB_DataPanel,'Style','text','String',CB_FileName,'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end
                              
    end

    function CB_ConvertButton_Callback(obj,event)
        cd ../bdf;
        disp('Converting .nev file to BDF structure, please wait...');
        out_struct = get_cerebus_data(CB_FullFileName,1);
        cd ../BMI_analysis;
        disp('Done.');
        
        disp('Saving BDF struct...');
        BDF_FileName =  strrep(CB_FileName,'.nev','.mat');
        [BDF_FileName, PathName] = saveDataStruct(out_struct,dataPath,BDF_FileName,'bdf');

        if isequal(BDF_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            BDF_FullFileName = fullfile(PathName, BDF_FileName);
            set(BDF_BinButton,'Enable','on');
            set(BDF_PlotButton,'Enable','on');
            
            BDF_FileLabel =  uicontrol('Parent',BDF_Panel,'Style','text','String',['BDFStruct : ' BDF_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end       
    end
    
    
    
%% BDF Panel

    %Buttons
    BDF_LoadButton = uicontrol('Parent', BDF_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@BDF_LoadButton_Callback,'Enable','on');

    BDF_BinButton = uicontrol('Parent', BDF_Panel, 'String', 'Bin Data', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@BDF_BinButton_Callback,'Enable','off');    
    
    BDF_PlotButton = uicontrol('Parent', BDF_Panel, 'String', 'Plot', 'Units','normalized',...
                            'Position', [.7 .2 .2 .3],'Callback',@BDF_PlotButton_Callback,'Enable','off');                     

    %Callbacks
    function BDF_LoadButton_Callback(obj,event)
        
        [BDF_FileName, PathName] = uigetfile([dataPath '\BDFStructs\*.mat'], 'Open BDF Data File');
        
        if isequal(BDF_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            BDF_FullFileName = fullfile(PathName, BDF_FileName);
            set(BDF_BinButton,'Enable','on');
            set(BDF_PlotButton,'Enable','on');
            
            BDF_FileLabel =  uicontrol('Parent',BDF_Panel,'Style','text','String',['BDFStruct : ' BDF_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end
        
        
    end
        
    function BDF_BinButton_Callback(obj,event)
        disp('Converting BDF structure to binned data, please wait...');
%        Bin_UI = figure;
        [binsize, starttime, stoptime, hpfreq, lpfreq] = convertBDF2binnedGUI;
        binnedData = convertBDF2binned(BDF_FullFileName,binsize,starttime,stoptime,hpfreq,lpfreq);
        disp('Done.');
        
        disp('Saving binned data...');
        Bin_FileName = BDF_FileName;
        [Bin_FileName, PathName] = saveDataStruct(binnedData,dataPath,Bin_FileName,'binned');
        
        if isequal(Bin_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            Bin_FullFileName = fullfile(PathName,Bin_FileName);
            set(Bin_BuildButton, 'Enable','on');
            set(Bin_BuildButton, 'Enable','on');
            set(Bin_PlotButton,  'Enable','on');
            if Filt_FileName
                set(Filt_PredButton,'Enable','on');
            end
            if OLPred_FileName
                set(OLPred_PlotVsActButton,'Enable','on');
                set(OLPred_R2VsActButton,'Enable','on');
            end
            if RTPred_FileName
                set(RTPred_R2VsActButton,'Enable','on');
                set(RTPred_PlotVsActButton,'Enable','on');
            end

            Bin_FileLabel = uicontrol('Parent',Bin_Panel,'Style','text','String',['Binned Data : ' Bin_FileName],'Units',...
                                      'normalized','Position',[0 .65 1 0.2]);
        end

    end

    function BDF_PlotButton_Callback(obj,event)
        plotBDF(BDF_FullFileName);        
    end
    
    
%% Binned Data Panel

    %Buttons
    Bin_LoadButton = uicontrol('Parent', Bin_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@Bin_LoadButton_Callback,'Enable','on');

    Bin_BuildButton = uicontrol('Parent', Bin_Panel, 'String', 'Build Model', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@Bin_BuildButton_Callback,'Enable','off');    
    
    Bin_PlotButton = uicontrol('Parent', Bin_Panel, 'String', 'Plot', 'Units','normalized',...
                            'Position', [.7 .2 .2 .3],'Callback',@Bin_PlotButton_Callback,'Enable','off');
    
    %Callbacks
    
    function Bin_LoadButton_Callback(obj,event)
        
        [Bin_FileName, PathName] = uigetfile([dataPath '\BinnedData\*.mat'], 'Open Binned Data File');
        
        if isequal(Bin_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            Bin_FullFileName = fullfile(PathName, Bin_FileName);
            
            set(Bin_BuildButton,'Enable','on');
            set(Bin_PlotButton, 'Enable','on');
            if Filt_FileName
                set(Filt_PredButton,'Enable','on');
            end
            if OLPred_FileName
                set(OLPred_R2VsActButton,'Enable','on');
                set(OLPred_PlotVsActButton,'Enable','on');
            end
            if RTPred_FileName
                set(RTPred_R2VsActButton,'Enable','on');
                set(RTPred_PlotVsActButton,'Enable','on');
            end
                        
            Bin_FileLabel =  uicontrol('Parent',Bin_Panel,'Style','text','String',['Binned Data : ' Bin_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end
    end
        
    function Bin_BuildButton_Callback(obj,event)
        disp('Building Prediction Model, please wait...');
        [filt_struct, OLPredData] = BuildModel(Bin_FullFileName);
        disp('Done.');
        
        disp('Saving prediction model...');
        Filt_FileName = [Bin_FileName(1:end-4) '_filter.mat'];
        [Filt_FileName, PathName] = saveDataStruct(filt_struct,dataPath,Filt_FileName,'filter');
        
        if isequal(Filt_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            Filt_FullFileName = fullfile(PathName,Filt_FileName);
            set(Filt_PredButton, 'Enable','on');

            Filt_FileLabel = uicontrol('Parent',Filt_Panel,'Style','text','String',['Model : ' Filt_FileName],'Units',...
                                      'normalized','Position',[0 .65 1 0.2]);
        end
        
        disp('Saving Offline EMG Predictions...');
        OLPred_FileName = [sprintf('OLPred_DATA-%s_Filter-%s', Bin_FileName(1:end-4),Filt_FileName(1:end-4)) '.mat'];
        [OLPred_FileName, PathName] = saveDataStruct(OLPredData,dataPath,OLPred_FileName,'OLpred');
        
        if isequal(OLPred_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            OLPred_FullFileName = fullfile(PathName,OLPred_FileName);
            set(OLPred_PlotVsActButton,'Enable','on');
            set(OLPred_R2VsActButton,'Enable','on');

            OLPred_FileLabel = uicontrol('Parent',OLPred_Panel,'Style','text','String',['OLPred : ' OLPred_FileName],'Units',...
                                      'normalized','Position',[0 .65 1 0.2]);
        end
        
    end

    function Bin_PlotButton_Callback(obj,event)
        disp('Function not available in demo version');
    end

%% Filter Panel

    %Buttons
    Filt_LoadButton = uicontrol('Parent', Filt_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@Filt_LoadButton_Callback,'Enable','on');

    Filt_PredButton = uicontrol('Parent', Filt_Panel, 'String', 'Predict', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@Filt_PredButton_Callback,'Enable','off');
      
    %Callbacks
    
    function Filt_LoadButton_Callback(obj,event)
        [Filt_FileName, PathName] = uigetfile([dataPath '\SavedFilters\*.mat'], 'Open Filter Data File');
        
        if isequal(Filt_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            Filt_FullFileName = fullfile(PathName, Filt_FileName);
            if Bin_FileName
                set(Filt_PredButton,'Enable','on');
            end
            
            Filt_FileLabel =  uicontrol('Parent',Filt_Panel,'Style','text','String',['Model : ' Filt_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end
    end

    function Filt_PredButton_Callback(obj,event)
        disp('Predicting EMGs, please wait...');
        OLPredData = predictEMGs(Filt_FullFileName,Bin_FullFileName);
        disp('Done.');
        
        disp('Saving predicted EMGs...');
        OLPred_FileName = [sprintf('OLPred_DATA-%s_Filter-%s', Bin_FileName(1:end-4),Filt_FileName(1:end-4)) '.mat'];
        [OLPred_FileName, PathName] = saveDataStruct(OLPredData,dataPath,OLPred_FileName,'OLpred');
        
        if isequal(OLPred_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            OLPred_FullFileName = fullfile(PathName,OLPred_FileName);
            set(OLPred_PlotVsActButton,'Enable','on');
            set(OLPred_R2VsActButton,'Enable','on');

            OLPred_FileLabel = uicontrol('Parent',OLPred_Panel,'Style','text','String',['OLPred : ' OLPred_FileName],'Units',...
                                      'normalized','Position',[0 .65 1 0.4]);
        end
        
        
    end
        
%% Offline Predictions Panel

    %Buttons
    OLPred_LoadButton = uicontrol('Parent', OLPred_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@OLPred_LoadButton_Callback,'Enable','on');
    
    OLPred_R2VsActButton = uicontrol('Parent', OLPred_Panel, 'String', 'R2 vs Actual', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@OLPred_R2VsActButton_Callback,'Enable','off');
    
    OLPred_PlotVsActButton = uicontrol('Parent', OLPred_Panel, 'String', 'Plot vs Actual', 'Units','normalized',...
                            'Position', [.7 .2 .2 .3],'Callback',@OLPred_PlotVsActButton_Callback,'Enable','off');
    
    %Callbacks
    function OLPred_LoadButton_Callback(obj,event)
        [OLPred_FileName, PathName] = uigetfile([dataPath '\OLPreds\*.mat'], 'Open Offline Predictions Data File');
        
        if isequal(OLPred_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            OLPred_FullFileName = fullfile(PathName, OLPred_FileName);
            if Bin_FileName
                set(OLPred_R2VsActButton,'Enable','on');
                set(OLPred_PlotVsActButton,'Enable','on');
            end
            
            OLPred_FileLabel =  uicontrol('Parent',OLPred_Panel,'Style','text','String',['OLPred : ' OLPred_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end
        
    end

    function OLPred_R2VsActButton_Callback(obj,event)
        disp('Loading data, please wait...');
        ActualData = LoadDatastruct(Bin_FullFileName,'binned');
        PredData = LoadDataStruct(OLPred_FullFileName,'OLpred');
        plotflag = 0;
        disp('Done. Processing R2 calculations...');
        ActualvsOLPred(ActualData,PredData,plotflag);   
    end

    function OLPred_PlotVsActButton_Callback(obj,event)
        disp('Loading data, please wait...');
        ActualData = LoadDatastruct(Bin_FullFileName,'binned');
        PredData = LoadDataStruct(OLPred_FullFileName,'OLpred');
        plotflag = 1;
        disp('Done. Calculating R2 and plotting...');
        ActualvsOLPred(ActualData,PredData,plotflag);
        disp('Done.');
    end

%% Real-Time Predictions Panel

%Buttons
    RTPred_LoadButton = uicontrol('Parent', RTPred_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@RTPred_LoadButton_Callback,'Enable','on');
    
    RTPred_R2VsActButton = uicontrol('Parent', RTPred_Panel, 'String', 'R2 vs Actual', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@RTPred_R2VsActButton_Callback,'Enable','off');
    
    RTPred_PlotVsActButton = uicontrol('Parent', RTPred_Panel, 'String', 'Plot vs Actual', 'Units','normalized',...
                            'Position', [.7 .2 .2 .3],'Callback',@RTPred_PlotVsActButton_Callback,'Enable','off');

    
    %Callbacks
    function RTPred_LoadButton_Callback(obj,event)
        [RTPred_FileName, PathName] = uigetfile([dataPath '\RTPreds\*.mat'], 'Open Real-Time Predictions Data File');
        
        if isequal(RTPred_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            RTPred_FullFileName = fullfile(PathName, RTPred_FileName);
            if Bin_FileName
                set(RTPred_R2VsActButton,'Enable','on');
                set(RTPred_PlotVsActButton,'Enable','on');
            end
            
            RTPred_FileLabel =  uicontrol('Parent',RTPred_Panel,'Style','text','String',['OLPred : ' RTPred_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end
    end

    function RTPred_R2VsActButton_Callback(obj,event)
        disp('Loading data, please wait...');
        ActualData = LoadDatastruct(Bin_FullFileName,'binned');
        PredData = LoadDataStruct(RTPred_FullFileName,'RTpred');
        plotflag = 0;
        disp('Done. Processing R2 calculations...');
        ActualvsRTPred(ActualData,PredData,plotflag);      
    end

    function RTPred_PlotVsActButton_Callback(obj,event)
        disp('Loading data, please wait...');
        ActualData = LoadDatastruct(Bin_FullFileName,'binned');
        PredData = LoadDataStruct(RTPred_FullFileName,'RTpred');
        plotflag = 1;
        disp('Done. Calculating R2 and plotting...');
        ActualvsRTPred(ActualData,PredData,plotflag);    
    end


%% Stimulator Commands Panel

    %Buttons
    
    
    %Callbacks
         
    
end