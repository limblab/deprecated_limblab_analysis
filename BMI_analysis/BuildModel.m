function [filter, PredData]=BuildModel(binnedData, dataPath)
    addpath ..\mimo\

    if ~isstruct(binnedData)
        binnedData = LoadDataStruct(binnedData, 'binned');
    end
    
    spikeguide = binnedData.spikeguide;
    emgdatabin = binnedData.emgdatabin;
    emgguide = binnedData.emgguide;
    spikeratedata = binnedData.spikeratedata;
    timeframe = binnedData.timeframe;
    binsize = timeframe(2)-timeframe(1);

    numberinputs=size(spikeguide,1);
    neuronChannels=zeros(numberinputs,2);
    for k=1:numberinputs
        temp=deblank(spikeguide(k,:));
        I = findstr(temp, 'u');
        neuronChannels(k,1)=str2double(temp(1,3:(I-1)));
        neuronChannels(k,2)=str2double(temp(1,(I+1):size(temp,2)));
        clear temp I
    end

    %%%Need to be able to find which column(s) is the requested input(s) and only
    %%%use those to build the models.
    %%
    %%%Default is to use all the available inputs, otherwise ask for a list of
    %%%the ones you want to use.
    %%
    %%%desiredInputs are the columns in the firing rate matrix that are to be
    %%%used as inputs for the models
    UseAllInputsOption=input('Use all available inputs? [y/n] ', 's');
    if UseAllInputsOption~='n'
        disp('Using all available inputs')
        neuronIDs=neuronChannels;
        desiredInputs=1:numberinputs;
     else
        [FileName, PathName] =uigetfile([dataPath '\NeuronIDfiles\' '*.mat'],'Filename of desired inputs? ');
        [neuronIDs] = loadneuronIDs([PathName FileName]);
        numberinputs=size(neuronIDs,1);
        for k=1:numberinputs
            temp=neuronIDs(k,:);
            spot=find((neuronChannels(:,1)==temp(1,1)) & (neuronChannels(:,2)==temp(1,2)));
            desiredInputs(1,k)=spot;
            clear temp spot
        end
    end


%% Calculate the filter

    desiredfiringrate=20; %50msec bins give you 20 Hz
%    desiredfiringrate=50; %20msec bins give you 50 Hz    
    lagtime = 250; % in ms, the laps of past time used to predict the EMG
    %desiredfiringrate=20; %In Hertz
    % lagtime = 500; % in ms, the laps of past time used to predict the EMG

    numlags=lagtime*desiredfiringrate/1000; %%%Designate the length of the filters/number of time lags
    %numlags=10;     %%%Designate the length of the filters/number of time lags
    numsides=1;     %%%For a one-sided or causal filter

    %numberbins=timelimit*60/binsize;
    %numberbins = length(timeframe);

    %%%Calculate the filters
    %fitteddata=24000; %%%4 min of data
    %fitteddata=36000; %%%6 min of data
    %fitteddata=numberbins; %%%all the available data3+
    
%    if isfield(binnedData,'timeframeave')
%        Inputs = binnedData.spikerateave(:,desiredInputs);
%        Outputs = binnedData.emgavebin;
%    else
       Inputs = spikeratedata(:,desiredInputs);
       Outputs=emgdatabin;
%    end

    %Inputs=spikeratedata(1:fitteddata,:); 
    %Inputs=spikeratedata(1:fitteddata,desiredInputs);
    %Outputs=emgdatabin(1:fitteddata,:);

    %%%The following calculates the linear filters (H) that relate the inputs and outputs
    [H,v,mcc]=filMIMO3(Inputs,Outputs,numlags,numsides,1);
    
%% Then, find polynomial and evaluate the model

    %% 1- Predict EMGs
    fs=1; numsides=1;
    
%    Inputs = spikeratedata(:,desiredInputs);
%    Outputs = emgdatabin;
    
    [PredictedEMGs,spikeDataNew,ActualEMGsNew]=predMIMO3(Inputs,H,numsides,fs,Outputs);

    %%%Find a Wiener Cascade Nonlinearity
    %PolynomialOrder=input('What order of Wiener Polynomial?  ');
    PolynomialOrder=2;
    R2 = zeros(size(PredictedEMGs,2),1);
    disp('R2 = ');

    for z=1:size(PredictedEMGs,2)
        [P(z,:)] = WienerNonlinearity(PredictedEMGs(:,z), ActualEMGsNew(:,z), PolynomialOrder);
        %[P(z,:)] = WienerNonlinearity([detrend(Y(:,z),'constant')+mean(Yact(:,z))], [detrend(Yact(:,z),'constant')+mean(Yact(:,z))], PolynomialOrder, 'plot');
        %[P] = WienerNonlinearity(Y, Yact, 2, 'plot');
        PredictedEMGs(:,z) = polyval(P(z,:),PredictedEMGs(:,z));
        R = corrcoef(PredictedEMGs(:,z),ActualEMGsNew(:,z));
        R2(z,1)=R(1,2).^2;
        disp(sprintf('%s\t%1.4f',emgguide(z,:),R2(z,1)));
    end
    aveR2 = mean(R2);
    disp(sprintf('Average:\t%1.4f',aveR2));

    fillen = lagtime/(binsize*1000);
    PredData = struct('predemgbin', PredictedEMGs, 'timeframe',timeframe(fillen:end),'spikeratedata',spikeDataNew,'emgguide',emgguide,'spikeguide',spikeguide);
    filter = struct('neuronIDs', neuronIDs, 'H', H, 'P', P, 'emgguide', emgguide,'fillen',fillen*binsize, 'binsize', binsize);

%% Save the filter data in a mat file
    %%%Need to save H and the inputs that you used (neuronIDs).
    
%     wanttosave = questdlg('Do you want to save the model?','Save model'); 
%     
%     if(strcmp('Yes',wanttosave))
%         
%         [FileName,PathName] = uiputfile('C:\Monkey\Theo\Data\SavedFilters\.mat', 'Save model as');
%         fullfilename = fullfile(PathName , FileName);
% 
%         if isequal(FileName,0) || isequal(PathName,0)
%             disp('The filter was not saved!')
%         else       
%              save(fullfilename, 'neuronIDs', 'H', 'P', 'filter');
%              disp(['File: ', fullfilename,' saved successfully'])
%         end
%     else
%         disp('The model was not saved!')
%     end
    
%% Save the EMG Predictions
% 
%     wanttosave = questdlg('Do you want to save the EMG Predictions?','Save Predictions'); 
%     
%     if(strcmp('Yes',wanttosave))
%     
%         [FileName,PathName] = uiputfile('C:\Monkey\Theo\Data\saved_pred\.mat', 'Save EMG Predictions as');
%         fullfilename = fullfile(PathName , FileName);
% 
%         if isequal(FileName,0) || isequal(PathName,0)
%             disp('The Predictions were not saved!')
%         else       
%              save(fullfilename, 'PredData');
%              disp(['File: ', fullfilename,' saved successfully'])
%         end
%     else
%         disp('The model was not saved!')
%     end
%    
end


