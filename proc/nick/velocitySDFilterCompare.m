% velocitySDFilterCompare.m
%
% calculates FIR, TF, coherence, and PSD for predictions
%
% dataType{monkey}(dataset,movepost,dim,:)
% monkey:
%   1 - Chewie
%   2 - Mini
% dataset:
%   1 to number of datasets
% movepost:
%   1 - movement
%   2 - posture
%   3 - general
% dim:
%   1 - x
%   2 - y
%   3 - speed

% set paths to include necessary functions
if (exist('BMI_analysis','dir') ~= 7)
    load_paths;
end

monkey{1} = 'Chewie'; monkey{2} = 'Mini';
datasets(1) = 9; datasets(2) = 10; % 9 files for Chewie and 10 for Mini
num_lags = 20; % for FIR
num_sides = 2; % for FIR
window = 128; % number of samples for spectral analysis

FIR = cell(1,length(monkey));
lags = cell(1,length(monkey));
TF = cell(1,length(monkey));
TFfreq = cell(1,length(monkey));
C = cell(1,length(monkey));
Cfreq = cell(1,length(monkey));
PSDpred = cell(1,length(monkey));
PSDreal = cell(1,length(monkey));

for m = 1:length(monkey)
    
    for dataset = 1:datasets(m)
        
        % load binnedData and decoder files
        load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_binned_' num2str(dataset) '.mat']);
        load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_decoder_' num2str(dataset) '.mat']);
        
        % calculate sampling frequency
        Fs = round(1/(binnedData.timeframe(2)-binnedData.timeframe(1)));

        for movepost = 1:3
            
            if movepost == 1
                decoder = movement_decoder;
            elseif movepost == 2
                decoder = posture_decoder;
            else
                decoder = general_decoder;
            end
    
            % transpose P matrix in decoder if necessary
            if size(decoder.P,1) ~= size(binnedData.velocbin,2)
                decoder.P = decoder.P';
            end

            
            [B,A] = butter(4,1/10,'low');
            binnedDataFilt = binnedData;
            binnedDataFilt.velocbin = filtfilt(B,A,double(binnedData.velocbin));
            
            
            % predict velocity
            pred = predictSignals(decoder,binnedData);
%             pred = predictSignals(decoder,binnedDataFilt);
            startindex = length(binnedData.velocbin) - length(pred.preddatabin) + 1;
            
            pred.preddatabin(:,3) = sqrt(pred.preddatabin(:,1).^2 + pred.preddatabin(:,2).^2);
            
            for dim = 1:3
                
                [FIR{m}(dataset,movepost,dim,:),vaf,mcc] = filMIMO3(binnedData.velocbin(startindex:end,dim),pred.preddatabin(:,dim),num_lags,num_sides,1);
                if num_sides == 1
                    lags{m}(dataset,:) = (0:num_lags)*decoder.binsize;
                elseif num_sides == 2
                    lags{m}(dataset,:) = (-(num_lags/2):num_lags/2)*decoder.binsize;
                end
                [TF{m}(dataset,movepost,dim,:),TFfreq{m}(dataset,:)] = tfestimate(binnedData.velocbin(startindex:end,dim),pred.preddatabin(:,dim),window,[],[],Fs);
                [C{m}(dataset,movepost,dim,:),Cfreq{m}(dataset,:)] = mscohere(binnedData.velocbin(startindex:end,dim),pred.preddatabin(:,dim),window,[],[],Fs);
                h = spectrum.welch('Hamming', floor(length(pred.preddatabin(:,dim))/window));
                PSDtemp = psd(h,pred.preddatabin(:,dim),'Fs',Fs);
                PSDpred{m}(dataset,movepost,dim,:) = PSDtemp.data;
                h = spectrum.welch('Hamming', floor(length(binnedData.velocbin(:,dim))/window));
                PSDtemp = psd(h,binnedData.velocbin(:,dim),'Fs',Fs);
%                 PSDtemp = psd(h,binnedData.velocbin(binnedData.velocbin(:,dim)<7,dim),'Fs',Fs);
                PSDreal{m}(dataset,dim,:) = PSDtemp.data;
                
            end
%             figure; plot(binnedData.velocbin(startindex:end,3),'k'); hold on; plot(pred.preddatabin(:,3),'r');
        end
    end
end