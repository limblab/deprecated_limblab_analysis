function BMIDataAnalyzer()
%GUI that process and plot data for Neural FES systems
%
%First thing to do: from s1_analysis folder, run 'load_paths', which
%will add all the necessary paths to the usefull files.
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
%           - PlexonData\  subfolder for storing .plx data
%           |               from Plexon
%           - NeuronIDfiles\ to store files specifying
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
%   this way. I added WS button for each type of file, which will load
%   the corresponding data into the Matlab's base workspace.
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
% $Id$
    
    
    
%% Globals
    
    dataPath = 'D:\Monkey\Spike\Data';
    dataPath = uigetdir(dataPath, 'Please choose the base data directory');
    Use_State =0;
    
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

    UI = figure('Units','normalized','Position',[.33 .125 .34 .75],'HitTest','off','NextPlot','new');
    set(UI,'Name','BMI Data Analyzer');
    set(UI,'NumberTitle','off');
    
    %vertical pannel position
    PanelsPos = linspace(0.025,0.975-0.13,7);
    
    CB_DataPanel = uipanel('Parent',UI,'Title','nev/plx Data','Position',[0.015 PanelsPos(7) .97 .13]);
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
        [CB_FileName, PathName] = uigetfile( {'*.nev;*.plx'},'Open .nev or .plx Data File',dataPath );
       

%         [CB_FileName, PathName] = uigetfile( { [dataPath '\CerebusData\*.nev'];[dataPath '\PlexonData\*.plx']},...
%                                                'Open .nev or .plx Data File' );
        
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
        if strcmp(CB_FileName(end-3:end),'.nev')
            disp('Converting .nev file to BDF structure, please wait...');
            out_struct = get_cerebus_data(CB_FullFileName,'verbose');
            disp('Done.');
            BDF_FileName =  strrep(CB_FileName,'.nev','.mat');
        elseif strcmp(CB_FileName(end-3:end),'.plx')
            disp('Converting .plx file to BDF structure, please wait...');
            out_struct = get_plexon_data(CB_FullFileName,'verbose');
            disp('Done.');
            BDF_FileName =  strrep(CB_FileName,'.plx','.mat');            
        end
        
        disp('Saving BDF struct...');
        [BDF_FileName, PathName] = saveDataStruct(out_struct,dataPath,BDF_FileName,'bdf');

        if isequal(BDF_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            BDF_FullFileName = fullfile(PathName, BDF_FileName);
            set(BDF_BinButton,'Enable','on');
            set(BDF_PlotButton,'Enable','on');
            set(BDF_WSButton,'Enable','on');
            
            BDF_FileLabel =  uicontrol('Parent',BDF_Panel,'Style','text','String',['BDFStruct : ' BDF_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end
        
        clear out_struct;
    end
    
    
    
%% BDF Panel

    %Buttons
    BDF_LoadButton = uicontrol('Parent', BDF_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@BDF_LoadButton_Callback,'Enable','on');

    BDF_BinButton = uicontrol('Parent', BDF_Panel, 'String', 'Bin Data', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@BDF_BinButton_Callback,'Enable','off');    
    
    BDF_PlotButton = uicontrol('Parent', BDF_Panel, 'String', 'Plot', 'Units','normalized',...
                            'Position', [.7 .2 .2 .3],'Callback',@BDF_PlotButton_Callback,'Enable','off');
                        
    BDF_WSButton = uicontrol('Parent', BDF_Panel, 'String', 'WS', 'Units','normalized',...
                            'Position', [.02 .2 .06 .3],'Callback',@BDF_WSButton_Callback,'Enable','off');

    %Callbacks
    function BDF_LoadButton_Callback(obj,event)
        
        [BDF_FileName, PathName] = uigetfile([dataPath '/BDFStructs/*.mat'], 'Open BDF Data File');
        
        if isequal(BDF_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            BDF_FullFileName = fullfile(PathName, BDF_FileName);
            set(BDF_BinButton,'Enable','on');
            set(BDF_WSButton,'Enable','on');
            
            BDF_FileLabel =  uicontrol('Parent',BDF_Panel,'Style','text','String',['BDFStruct : ' BDF_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
        end
        
        
    end
        
    function BDF_BinButton_Callback(obj,event)
        disp('Converting BDF structure to binned data, please wait...');
%        Bin_UI = figure;
        [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate,NormData, FindStates, Unsorted, TriKernel, sig] = convertBDF2binnedGUI;  %Added Unsorted TriKernel and sig 3/14/12 SNN
        binnedData = convertBDF2binned(BDF_FullFileName,binsize,starttime,stoptime,hpfreq,lpfreq,MinFiringRate,NormData, FindStates, Unsorted, TriKernel, sig);
  
        if FindStates
            [states,statemethods] = findStates(binnedData);
            binnedData.states = states;
            binnedData.statemethods = statemethods;
            clear states statemethods;
        end
        
        
        disp('Done.');
        
        disp('Saving binned data...');
        Bin_FileName = BDF_FileName;
        [Bin_FileName, PathName] = saveDataStruct(binnedData,dataPath,Bin_FileName,'binned');
        
        if isequal(Bin_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            Bin_FullFileName = fullfile(PathName,Bin_FileName);
            set(Bin_BuildButton, 'Enable','on');
            set(Bin_ClassButton, 'Enable','on');
            set(Bin_WSButton, 'Enable','on');
            set(Bin_mfxvalButton,  'Enable','on');
            set(Bin_PlotButton, 'Enable','on');
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
        
        clear binsize starttime stoptime hpfreq lpfreq MinFiringRate NormData FindStates;
        clear binnedData;

    end


    function BDF_PlotButton_Callback(obj,event)
        plotBDF(BDF_FullFileName);        
    end

    function BDF_WSButton_Callback(obj,event)
        assignin('base','temp_str',BDF_FullFileName);
        evalin('base','load(temp_str);');
        evalin('base','clear(''temp_str'')');
    end
    
    
%% Binned Data Panel

    %Buttons
    Bin_LoadButton = uicontrol('Parent', Bin_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .15 .3],'Callback',@Bin_LoadButton_Callback,'Enable','on');

    Bin_BuildButton = uicontrol('Parent', Bin_Panel, 'String', 'Build Model', 'Units','normalized',...
                            'Position', [.2625 .2 .15 .3],'Callback',@Bin_BuildButton_Callback,'Enable','off');    

    Bin_ClassButton = uicontrol('Parent', Bin_Panel, 'String', 'Classify', 'Units','normalized',...
                            'Position', [.425 .2 .15 .3],'Callback',@Bin_ClassButton_Callback,'Enable','off');                            
                                               
    Bin_mfxvalButton = uicontrol('Parent', Bin_Panel, 'String', 'mfxval', 'Units','normalized',...
                            'Position', [.5875 .2 .15 .3],'Callback',@Bin_mfxvalButton_Callback,'Enable','off');
                        
    Bin_PlotButton   = uicontrol('Parent', Bin_Panel, 'String', 'Plot', 'Units', 'normalized',...
                            'Position', [.75 .2 .15 .3],'Callback',@Bin_PlotButton_Callback,'Enable','off');
                        
    Bin_WSButton = uicontrol('Parent', Bin_Panel, 'String', 'WS', 'Units','normalized',...
                            'Position', [.02 .2 .06 .3],'Callback',@Bin_WSButton_Callback,'Enable','off');                        
    
    %Callbacks
    
    function Bin_LoadButton_Callback(obj,event)
        
        [Bin_FileName, PathName] = uigetfile([dataPath '/BinnedData/*.mat'], 'Open Binned Data File');
        
        if isequal(Bin_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            Bin_FullFileName = fullfile(PathName, Bin_FileName);
            
            set(Bin_BuildButton,'Enable','on');
            set(Bin_WSButton,'Enable','on');
            set(Bin_mfxvalButton, 'Enable','on');
            set(Bin_PlotButton, 'Enable','on');
            set(Bin_ClassButton,'Enable','on');
            if Filt_FileName
                set(Filt_PredButton,'Enable','on');
                set(Filt_WSButton,'Enable','on');
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
        
        binnedData = LoadDataStruct(Bin_FullFileName);
        binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
        
        statemethods=[];
        if isfield(binnedData,'statemethods')
            [m,n]=size(binnedData.statemethods);
            statemethods = mat2cell(binnedData.statemethods,ones(1,m),n);
        end
        
        [fillen, UseAllInputsOption, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos, Pred_Veloc,Use_State,Use_Thresh,Use_Ridge,Use_EMGs] = BuildModelGUI(binsize,statemethods);
        if isempty(fillen)
            %user hit cancel
            disp('Cancelled');
            return;
        end
        if Use_State
            [filt_struct] = BuildSDModel(binnedData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos, Pred_Veloc, Use_State);
        elseif Use_Ridge
            [filt_struct] = BuildRidgeModel(binnedData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos, Pred_Veloc, Use_State);
        else [filt_struct, OLPredData] = BuildModel(binnedData, dataPath, fillen, UseAllInputsOption, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos, Pred_Veloc, Use_Thresh, Use_EMGs);
        end
        disp('Done.');
        
        if isempty(filt_struct)
            disp('Model Building Failed');
            return;
        end     
        
        disp('Saving prediction model...');
        Filt_FileName = [Bin_FileName(1:end-4) '_Decoder.mat'];
        if ~Use_State
            filt_struct.FromData = Bin_FileName;
            [Filt_FileName, PathName] = saveDataStruct(filt_struct,dataPath,Filt_FileName,'filter');            
        else
            %state dependent filters, filt_struct is a cell array:
            for i=1:size(filt_struct,2)
                filt_struct{1,i}.FromData = Bin_FileName;
            end
            general_decoder = filt_struct{1};
            posture_decoder = filt_struct{2};
            movement_decoder= filt_struct{3};
            
            [Filt_FileName,PathName] = uiputfile( fullfile([dataPath '\SavedFilters\'],Filt_FileName), 'Save file');
        end
        
        if isequal(Filt_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            Filt_FullFileName = fullfile(PathName,Filt_FileName);
            if ~Use_State
                %Eventually the following line should not be necessary when we can read structures from NLMS or reach-rt...
                save(Filt_FullFileName, '-append','-struct','filt_struct');    %append "extracted" variables from structures
            else
                %This assumes class methods={velthres,CompBayes,PeakBayes,CompLDA,PeakLDA};
                ClassMethods = {'Vel Thresh','Complete Bayes','Peak Bayes','Complete LDA', 'Peak LDA'};
                VelThresh = 1; CompBayes = 2; PeakBayes = 3; CompLDA = 4; PeakLDA = 5;
                switch Use_State
                    case VelThresh
                        posture_classifier = binnedData.classifiers{1};
                        movement_classifier= binnedData.classifiers{1};
                    case CompBayes
                        posture_classifier = binnedData.classifiers{2};
                        movement_classifier= binnedData.classifiers{2};
                    case PeakBayes
                        posture_classifier = binnedData.classifiers{3};
                        movement_classifier= binnedData.classifiers{3};
                    case CompLDA
                        posture_classifier = binnedData.classifiers{4}{1};
                        movement_classifier= binnedData.classifiers{4}{2};
                    case PeakLDA
                        posture_classifier = binnedData.classifiers{5}{1};
                        movement_classifier= binnedData.classifiers{5}{2};
                end
                save(Filt_FullFileName, 'general_decoder','posture_decoder','movement_decoder',...
                                        'posture_classifier','movement_classifier');
                disp(['File: ', Filt_FullFileName,' saved successfully']);
            end
            set(Filt_PredButton, 'Enable','on');
            set(Filt_WSButton,'Enable','on');            
            Filt_FileLabel = uicontrol('Parent',Filt_Panel,'Style','text','String',['Model : ' Filt_FileName],'Units',...
                                      'normalized','Position',[0 .65 1 0.2]);
        end
        if ~Use_State
            %no Predictions are made at this stage when State dependent algorithm is built
            disp('Saving Offline EMG Predictions...');
            OLPred_FileName = [sprintf('OLPred_DATA-%s_Filter-%s', Bin_FileName(1:end-4),Filt_FileName(1:end-4)) '.mat'];
            [OLPred_FileName, PathName] = saveDataStruct(OLPredData,dataPath,OLPred_FileName,'OLpred');

            if isequal(OLPred_FileName, 0) || isequal(PathName,0)
                disp('User action cancelled');
            else
                OLPred_FullFileName = fullfile(PathName,OLPred_FileName);
                set(OLPred_PlotVsActButton,'Enable','on');
                set(OLPred_R2VsActButton,'Enable','on');
                set(OLPred_WSButton,'Enable','on');

                OLPred_FileLabel = uicontrol('Parent',OLPred_Panel,'Style','text','String',['OLPred : ' OLPred_FileName],'Units',...
                                          'normalized','Position',[0 .65 1 0.38]);
            end
        end
        clear binnedData OLPredData filt_struct posture_decoder movement_decoder general_decoder posture_classifier movement_classifier;
        clear fillen UseAllInputsOption PolynomialOrder Pred_EMG Pred_Force Pred_CursPos Pred_Veloc Use_State;
    end

    function Bin_ClassButton_Callback(obj,event)
        disp('Training classifiers, please wait...');
        binnedData = LoadDataStruct(Bin_FullFileName);
        binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
        [states,statemethods,classifiers]=findStates(binnedData);

        disp('Done.');

        binnedData.states = states;
        binnedData.statemethods = statemethods;
        binnedData.classifiers = classifiers;

        [Bin_FileName, PathName] = saveDataStruct(binnedData,dataPath,strrep(Bin_FileName,'.mat','_class.mat'),'binned');
                
        if isequal(Bin_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            Bin_FullFileName = fullfile(PathName,Bin_FileName);

            Bin_FileLabel = uicontrol('Parent',Bin_Panel,'Style','text','String',['Binned Data : ' Bin_FileName],'Units',...
                                      'normalized','Position',[0 .65 1 0.2]);
        end
        
        clear binnedData states statemethods classifiers;
        
    end

    function mfxval_R2 = Bin_mfxvalButton_Callback(obj,event)
        
        binnedData = LoadDataStruct(Bin_FullFileName);
        binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
        
        statemethods=[];
        if isfield(binnedData,'statemethods')
            [m,n]=size(binnedData.statemethods);
            statemethods = mat2cell(binnedData.statemethods,ones(1,m),n);
        end
        
        [fillen, UseAllInputsOption, PolynomialOrder, fold_length, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States] = mfxvalGUI(binsize, statemethods);        
        disp(sprintf('Proceeding to multifold cross-validation using %g sec folds...', fold_length));
        plotflag = 1;
        if Use_States
            [mfxval_R2, mfxval_vaf, mfxval_mse, OLPredData] = mfxvalSD(binnedData, dataPath, fold_length, fillen, UseAllInputsOption, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
        else
            [mfxval_R2, mfxval_vaf, mfxval_mse, OLPredData] = mfxval(binnedData, dataPath, fold_length, fillen, UseAllInputsOption, PolynomialOrder, PredEMG, PredForce, PredCursPos, PredVeloc, Use_States,plotflag);
        end
            
        %put the results in the base workspace for easy access
        assignin('base','mfxval_R2',mfxval_R2);
        assignin('base','mfxval_vaf',mfxval_vaf);
        assignin('base','mfxval_mse',mfxval_mse);
        ave_R2 = mean(mfxval_R2);
        assignin('base','ave_R2',ave_R2);

        disp('Done.');

        disp('Saving Offline EMG Predictions...');
        OLPred_FileName = [sprintf('OLPred_mfxval_%s', Bin_FileName(1:end-4)) '.mat'];
        [OLPred_FileName, PathName] = saveDataStruct(OLPredData,dataPath,OLPred_FileName,'OLpred');

        if isequal(OLPred_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            OLPred_FullFileName = fullfile(PathName,OLPred_FileName);
            set(OLPred_PlotVsActButton,'Enable','on');
            set(OLPred_R2VsActButton,'Enable','on');
            set(OLPred_WSButton,'Enable','on');

            OLPred_FileLabel = uicontrol('Parent',OLPred_Panel,'Style','text','String',['OLPred : ' OLPred_FileName],'Units',...
                                      'normalized','Position',[0 .65 1 0.38]);
        end

        clear binnedData OLPredData;
        clear fillen UseAllInputsOption PolynomialOrder fold_length PredEMG PredForce PredCursPos PredVeloc Use_States;
        
    end

    function Bin_PlotButton_Callback(obj,event)
         plotBin(Bin_FullFileName);
    end

    function Bin_WSButton_Callback(obj,event)
        assignin('base','temp_str',Bin_FullFileName);
        evalin('base','load(temp_str);');
        evalin('base','clear(''temp_str'')');
    end
    


%% Filter Panel

    %Buttons
    Filt_LoadButton = uicontrol('Parent', Filt_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@Filt_LoadButton_Callback,'Enable','on');

    Filt_PredButton = uicontrol('Parent', Filt_Panel, 'String', 'Predict', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@Filt_PredButton_Callback,'Enable','off');

    Filt_WSButton = uicontrol('Parent', Filt_Panel, 'String', 'WS', 'Units','normalized',...
                            'Position', [.02 .2 .06 .3],'Callback',@Filt_WSButton_Callback,'Enable','off');                        
      
    %Callbacks
    
    function Filt_LoadButton_Callback(obj,event)
        [Filt_FileName, PathName] = uigetfile([dataPath '/SavedFilters/*.mat'], 'Open Filter Data File');
        
        if isequal(Filt_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            Filt_FullFileName = fullfile(PathName, Filt_FileName);
            set(Filt_WSButton,'Enable','on');
            
            if Bin_FileName
                set(Filt_PredButton,'Enable','on');
            end
            
            Filt_FileLabel =  uicontrol('Parent',Filt_Panel,'Style','text','String',['Model : ' Filt_FileName],'Units',...
                                  'normalized','Position',[0 .65 1 0.2]);
            tmpfilt = load(Filt_FullFileName);
            Use_State = iscell(tmpfilt);
            if Use_State
                disp('This file includes multiple models with state classification, method 1 will be used');
            end
            clear tmpfilt;
        end
    end

    function Filt_PredButton_Callback(obj,event)
        disp('Predicting, please wait...');
        [Smooth_Pred, Adapt.Enable, Adapt.LR, Adapt.Lag] = PredOptionsGUI();
        
        decoder = load(Filt_FullFileName);
        field_names = fieldnames(decoder);
        if any(strcmp(field_names,'posture_decoder'))
            Use_State = 1;
            [OLPredData, H_new] = predictSDSignals(decoder,Bin_FullFileName,Use_State,Smooth_Pred,Adapt);
        else
            Use_State = 0;
            [OLPredData, H_new] = predictSignals(Filt_FullFileName,Bin_FullFileName,Smooth_Pred,Adapt);
        end
        
        disp('Done.');
        
        if Adapt.Enable %we have a new filter
            disp('Saving updated prediction model...');
            Filt_FileName = [Bin_FileName(1:end-4) '_adaptFilter.mat'];
            filt_struct = LoadDataStruct(Filt_FullFileName);
            filt_struct.H = H_new;            
            [Filt_FileName, PathName] = saveDataStruct(filt_struct,dataPath,Filt_FileName,'filter');

            if isequal(Filt_FileName, 0) || isequal(PathName,0)
                disp('User action cancelled, new filter was not saved');
            else
                Filt_FullFileName = fullfile(PathName,Filt_FileName);
                set(Filt_PredButton, 'Enable','on');
                set(Filt_WSButton,'Enable','on');

                Filt_FileLabel = uicontrol('Parent',Filt_Panel,'Style','text','String',['Model : ' Filt_FileName],'Units',...
                                          'normalized','Position',[0 .65 1 0.2]);
            end
        end
            
        disp('Saving predictions...');
        OLPred_FileName = [sprintf('OLPred_DATA-%s_Filter-%s', Bin_FileName(1:end-4),Filt_FileName(1:end-4)) '.mat'];
        [OLPred_FileName, PathName] = saveDataStruct(OLPredData,dataPath,OLPred_FileName,'OLpred');
        
        if isequal(OLPred_FileName, 0) || isequal(PathName,0)
            disp('User action cancelled');
        else
            OLPred_FullFileName = fullfile(PathName,OLPred_FileName);
            set(OLPred_PlotVsActButton,'Enable','on');
            set(OLPred_R2VsActButton,'Enable','on');
            set(OLPred_WSButton,'Enable','on');

            OLPred_FileLabel = uicontrol('Parent',OLPred_Panel,'Style','text','String',['OLPred : ' OLPred_FileName],'Units',...
                                      'normalized','Position',[0 .65 1 0.38]);
        end
        
        clear Smooth_Pred Adapt;
        clear OLPredData H_new;
        clear filt_struct decoder Use_State;
    end

    function Filt_WSButton_Callback(obj,event)
%         datastruct = LoadDataStruct(Filt_FullFileName);
%         assignin('base','filter',datastruct);
          assignin('base','temp_str',Filt_FullFileName);
          evalin('base','load(temp_str);');
          evalin('base','clear(''temp_str'');');
    end
        
%% Offline Predictions Panel

    %Buttons
    OLPred_LoadButton = uicontrol('Parent', OLPred_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@OLPred_LoadButton_Callback,'Enable','on');
    
    OLPred_R2VsActButton = uicontrol('Parent', OLPred_Panel, 'String', 'R2 vs Actual', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@OLPred_R2VsActButton_Callback,'Enable','off');
    
    OLPred_PlotVsActButton = uicontrol('Parent', OLPred_Panel, 'String', 'Plot vs Actual', 'Units','normalized',...
                            'Position', [.7 .2 .2 .3],'Callback',@OLPred_PlotVsActButton_Callback,'Enable','off');
                        
    OLPred_WSButton = uicontrol('Parent', OLPred_Panel, 'String', 'WS', 'Units','normalized',...
                            'Position', [.02 .2 .06 .3],'Callback',@OLPred_WSButton_Callback,'Enable','off');                        
    
    %Callbacks
    function OLPred_LoadButton_Callback(obj,event)
        [OLPred_FileName, PathName] = uigetfile([dataPath '/OLPreds/*.mat'], 'Open Offline Predictions Data File');
        
        if isequal(OLPred_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            OLPred_FullFileName = fullfile(PathName, OLPred_FileName);
            set(OLPred_WSButton,'Enable','on');
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
        ActualData = LoadDataStruct(Bin_FullFileName);
        PredData = LoadDataStruct(OLPred_FullFileName);
        plotflag = 0;
        dispflag = 1;
        disp('Done. Processing R2 calculations...');
        ActualvsOLPred(ActualData,PredData,plotflag,dispflag);   
        clear ActualData PredData plotflag dispflag;
    end

    function OLPred_PlotVsActButton_Callback(obj,event)
        disp('Loading data, please wait...');
        ActualData = LoadDataStruct(Bin_FullFileName);
        PredData = LoadDataStruct(OLPred_FullFileName);
        plotflag = 1;
        dispflag = 1;
        disp('Done. Calculating R2 and plotting...');
        ActualvsOLPred(ActualData,PredData,plotflag,dispflag);
        disp('Done.');
        clear ActualData PredData plotflag dispflag;
    end

    function OLPred_WSButton_Callback(obj,event)
        assignin('base','temp_str',OLPred_FullFileName);
        evalin('base','load(temp_str);');
        evalin('base','clear(''temp_str'')');
    end

%% Real-Time Predictions Panel

%Buttons
    RTPred_LoadButton = uicontrol('Parent', RTPred_Panel, 'String', 'LOAD', 'Units','normalized',...
                            'Position', [.1 .2 .2 .3],'Callback',@RTPred_LoadButton_Callback,'Enable','on');
    
    RTPred_R2VsActButton = uicontrol('Parent', RTPred_Panel, 'String', 'R2 vs Actual', 'Units','normalized',...
                            'Position', [.4 .2 .2 .3],'Callback',@RTPred_R2VsActButton_Callback,'Enable','off');
    
    RTPred_PlotVsActButton = uicontrol('Parent', RTPred_Panel, 'String', 'Plot vs Actual', 'Units','normalized',...
                            'Position', [.7 .2 .2 .3],'Callback',@RTPred_PlotVsActButton_Callback,'Enable','off');

    RTPred_WSButton = uicontrol('Parent', RTPred_Panel, 'String', 'WS', 'Units','normalized',...
                            'Position', [.02 .2 .06 .3],'Callback',@RTPred_WSButton_Callback,'Enable','off');  
                        
    %Callbacks
    function RTPred_LoadButton_Callback(obj,event)
        [RTPred_FileName, PathName] = uigetfile([dataPath '/RTPreds/*.mat'], 'Open Real-Time Predictions Data File');
        
        if isequal(RTPred_FileName,0) || isequal(PathName,0)
          disp('User action cancelled');
        else
            RTPred_FullFileName = fullfile(PathName, RTPred_FileName);
            set(RTPred_WSButton,'Enable','on');
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
        ActualData = LoadDataStruct(Bin_FullFileName);
        PredData = LoadDataStruct(RTPred_FullFileName);
        plotflag = 0;
        disp('Done. Processing R2 calculations...');
        ActualvsRTPred(ActualData,PredData,plotflag);
        clear ActualData PredData plotflag;
    end

    function RTPred_PlotVsActButton_Callback(obj,event)
        disp('Loading data, please wait...');
        ActualData = LoadDataStruct(Bin_FullFileName);
        PredData = LoadDataStruct(RTPred_FullFileName);
        plotflag = 1;
        disp('Done. Calculating R2 and plotting...');
        ActualvsRTPred(ActualData,PredData,plotflag);    
        clear ActualData PredData plotflag;
    end

    function RTPred_WSButton_Callback(obj,event)
        assignin('base','temp_str',RTPred_FullFileName);
        evalin('base','load(temp_str);');
        evalin('base','clear(''temp_str'')');
    end

%% Stimulator Commands Panel

    %Buttons
    
    
    %Callbacks
         
    
end