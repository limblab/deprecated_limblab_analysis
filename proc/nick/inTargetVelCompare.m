% inTargetVelCompare.m
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

holdVel = cell(1,length(monkey));
actualHoldVel = cell(1,length(monkey));
moveVel = cell(1,length(monkey));
actualMoveVel = cell(1,length(monkey));

for m = 1:length(monkey)
    
    for dataset = 1:datasets(m)
        
        % load binnedData and decoder files
        load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_binned_' num2str(dataset) '.mat']);
        load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_decoder_' num2str(dataset) '.mat']);
        
        % calculate sampling frequency
        Fs = round(1/(binnedData.timeframe(2)-binnedData.timeframe(1)));

        % determine when the cursor is in the target
        binnedData.inTarget = false(size(binnedData.timeframe));
        for x = 1:length(binnedData.timeframe)
            if binnedData.timeframe(x) > binnedData.words(1,1)
                currentWord = binnedData.words(find(binnedData.words(:,1) < binnedData.timeframe(x),1,'last'),2);
                if currentWord == 160 % word for target entry
%                 if currentWord == 49 % word for target appearance
                    binnedData.inTarget(x) = true;
                end
            end
        end
            
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
            
            % predict velocity
            pred = predictSignals(decoder,binnedData);
            startindex = length(binnedData.velocbin) - length(pred.preddatabin) + 1;
            
            pred.preddatabin(:,3) = sqrt(pred.preddatabin(:,1).^2 + pred.preddatabin(:,2).^2);
            
            for dim = 1:3
                
                holdVel{m}{dataset}(movepost,dim,:) = pred.preddatabin(binnedData.inTarget(startindex:end),dim);
                actualHoldVel{m}{dataset}(dim,:) = binnedData.velocbin(binnedData.inTarget,dim);

                moveVel{m}{dataset}(movepost,dim,:) = pred.preddatabin(~binnedData.inTarget(startindex:end),dim);
                actualMoveVel{m}{dataset}(dim,:) = binnedData.velocbin(~binnedData.inTarget,dim);

            end
        end
    end
end

speed = [];
for x = 1:2
    for y = 1:length(holdVel{x})
        speed = [speed; squeeze(holdVel{x}{y}(1,3,:))];
    end
end
moveSpeed = mean(speed)
moveSpeedSTD = std(speed)

speed = [];
for x = 1:2
    for y = 1:length(holdVel{x})
        speed = [speed; squeeze(holdVel{x}{y}(2,3,:))];
    end
end
postSpeed = mean(speed)
postSpeedSTD = std(speed)

speed = [];
for x = 1:2
    for y = 1:length(holdVel{x})
        speed = [speed; squeeze(holdVel{x}{y}(3,3,:))];
    end
end
genSpeed = mean(speed)
genSpeedSTD = std(speed)

speed = [];
for x = 1:2
    for y = 1:length(actualHoldVel{x})
        speed = [speed; squeeze(actualHoldVel{x}{y}(3,:))'];
    end
end
actualSpeed = mean(speed)
actualSpeedSTD = std(speed)
% 
% 
% speed = [];
% for x = 1:2
%     for y = 1:length(moveVel{x})
%         speed = [speed; squeeze(moveVel{x}{y}(1,3,:))];
%     end
% end
% moveSpeed = mean(speed)
% moveSpeedSTD = std(speed)
% 
% speed = [];
% for x = 1:2
%     for y = 1:length(moveVel{x})
%         speed = [speed; squeeze(moveVel{x}{y}(2,3,:))];
%     end
% end
% postSpeed = mean(speed)
% postSpeedSTD = std(speed)
% 
% speed = [];
% for x = 1:2
%     for y = 1:length(actualMoveVel{x})
%         speed = [speed; squeeze(actualMoveVel{x}{y}(3,:))'];
%     end
% end
% actualSpeed = mean(speed)
% actualSpeedSTD = std(speed)
