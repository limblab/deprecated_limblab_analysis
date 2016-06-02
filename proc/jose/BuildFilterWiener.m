function [filt_struct, OffLPredData, trainData R2] = BuildFilterWiener(EMGvector,PolynomialOrder)

% BuildFilterWiener: build a wiener decoder from a data set
% EMGvector        : number of EMG outputs you want to take.
% %                  e.g: 1:9 -> select first 9 muscles fromthe data set
% PolynomialOrder  : order of the Weiner non-linearity (0=no Polynomial)
% dataset          : is selected by user from uigetfile
% filt_struct      : structure containing the decoders weights
% OffLPredData     : Off-Line Predicted from the decoder
% trainData        : get new Data set after selecting desired muscles  
% % By Jose: jose.albsab@gmail.com  / 10-18-12

%% Loading dataset
% Default Path

dataPath = ':\';
disp('You are going to select your dataset, be careful!!')
disp('dataset in workspace: 1 (note dataset should be named as binnedData)')
disp('dataset in folder   : 2 ')
option = input('select 1 or 2 --> ');

while(option~=1 && option~=2)
disp('please enter only 1 or 2 \n');
option = input('select 1 or 2 --> ');
end

if(option == 1)
        binnedData = evalin('base', 'binnedData');
        disp('Remember: should be a binnedData in workspace')
    elseif(option == 2)
        % Call GUI
        [FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose First BinnedData File');
        datafile = fullfile(PathName,FileName_tmp);
        % Verify if the file indeed exists
        if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
            % It exists.
            load(datafile); % datafile automatically loaded as binnedData
        else
            % It doesn't exist.
            warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found', ...
            datafile);
            uiwait(warndlg(warningMessage));
        end
end

%% Cutting the dataset to work only with the desired muscles
% Cut the dataset to use only the selected muscles 
binnedData.emgguide = binnedData.emgguide(EMGvector,:);
binnedData.emgdatabin = binnedData.emgdatabin(:,EMGvector);
% Saving new data set
trainData = binnedData; 
%% Building Decoder
UseAllInputsOption = 1; % use all inputs
fillen = 0.5;            % filter length (in seconds)
%% Output
[filt_struct, OffLPredData] = BuildModel(trainData,dataPath,fillen,UseAllInputsOption,PolynomialOrder);
binsize = filt_struct.binsize;
numlags = round(filt_struct.fillen/binsize);
R2 = CalculateR2(trainData.emgdatabin(numlags:end,:),OffLPredData.preddatabin);
