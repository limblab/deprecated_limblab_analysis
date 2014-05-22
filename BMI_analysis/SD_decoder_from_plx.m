function SD_decoder_from_plx(plx_file,use_distance,threshold,unsorted)
% SD_decoder_from_plx(plx_file,use_distance,threshold,unsorted)
%
% Builds an LDA-based state dependent decoder from a plx file and saves the
% bdf, binnedData, and decoder files in the same directory as the original
% plx file. Primarily for use mid-session to build a decoder on the fly.
%
% PLX_FILE is a string containing the path and plx file name.
% USE_DISTANCE is a flag to indicate which metric to use for determining
% ground truth posture and movement.
%   0 - speed
%   1 - distance
% THRESHOLD is the threshold value (either speed in cm/s or distance in cm)
% used to differentiate posture and movement.
% UNSORTED is a flag to indicate whether to include unsorted waveforms

disp('Converting .plx file to BDF structure...');
[~,~,plx_file_extension] = fileparts(plx_file);
if strcmp(plx_file_extension,'.mat')
    load(plx_file);
    bdf_file = plx_file;
else
    out_struct = get_plexon_data(plx_file,'verbose');
    bdf_file = strrep(plx_file,'.plx','.mat');
    disp(['Saving BDF file as ' bdf_file '...']);
    save(bdf_file,'out_struct');
end

disp('Converting BDF to binnedData file...');
% binnedData = convertBDF2binned(bdf_file,0.05,1,0,50,10,0,0,0,unsorted);
options = struct('binsize',0.05,'starttime',1,'stoptime',0,'FindStates',false,'Unsorted',unsorted);
binnedData = convertBDF2binned(bdf_file,options);

disp('Finding states...')
if use_distance
    x_offset = bytes2float(out_struct.databursts{1,2}(7:10));
    y_offset = bytes2float(out_struct.databursts{1,2}(11:14));
    target = ones(length(binnedData.timeframe),2)*1000;
    target_distance = zeros(length(target),1);
    target_flag = 0;
    target_index = 0;
    word_index = 0;
    trial = 0;
    hold_time = 0.8; % change if necessary
    for x = 1:length(target)
        if word_index < length(binnedData.words)
            if binnedData.timeframe(x) >= binnedData.words(word_index+1,1)
                word_index = word_index + 1;
                word = binnedData.words(word_index,2);
                if word == 18
                    trial = trial + 1;
                    target_index = 0;
                end
                if trial > 0 && word == 49
                    if target_index == 0 || (binnedData.words(word_index,1) - binnedData.words(word_index-1,1) >= (hold_time+.01) && target_index < 3)
                        target_index = target_index + 1;
                        target_flag = 1;
                    end
                elseif word == 32
                       target_flag = 0;
                end    
%             else
%                 target_index = 0;
%                 target_flag = 0;
            end
        end
        
        % HACK!
        
        target_index = min(target_index,1);
        
        if target_flag
            target(x,1) = binnedData.targets.centers(trial, target_index*2 + 1);
            target(x,2) = binnedData.targets.centers(trial, target_index*2 + 2);
        end
        target_distance(x) = sqrt((target(x,1)-binnedData.cursorposbin(x,1)-x_offset)^2 + (target(x,2)-binnedData.cursorposbin(x,2)-y_offset)^2);
        if target_distance(x) > 100
            target_distance(x) = 0;
        end
    end
    binnedData.states(:,1) = (target_distance >= threshold);
    binnedData.statemethods(1,1:8) = 'Distance';
    binnedData.classifiers{1} = threshold;
    binsize = round(1000*(binnedData.timeframe(2)-binnedData.timeframe(1)))/1000;
    [binnedData.states(:,2), binnedData.classifiers{2}] = perf_LDA_clas(binnedData.spikeratedata,binsize,target_distance,threshold);
    binnedData.statemethods(2,1:12) = 'Complete LDA';
else
    binnedData.states(:,1) = binnedData.velocbin(:,3) >= threshold;
    binnedData.statemethods(1,1:10) = 'Vel Thresh';
    binnedData.classifiers{1} = threshold;
    binsize = round(1000*(binnedData.timeframe(2)-binnedData.timeframe(1)))/1000;
    [binnedData.states(:,2), binnedData.classifiers{2}] = perf_LDA_clas(binnedData.spikeratedata,binsize,binnedData.velocbin(:,3),threshold);
    binnedData.statemethods(2,1:12) = 'Complete LDA';
end

binned_file = strrep(bdf_file,'.mat','-binned_class.mat');
disp(['Saving binnedData file as ' binned_file '...']);
save(binned_file,'binnedData');

disp('Building decoder...');
options = struct('fillen',0.5,'UseAllInputs',1,'PolynomialOrder',1,'PredVeloc',1,'Use_SD',1);
filt_struct = BuildSDModel(binnedData,options);
% filt_struct = BuildSDModel(binnedData,'',0.5,1,1,0,0,0,1,2); % change last to 1 to use GT as training set for H
decoder.general_decoder = filt_struct{1};
decoder.posture_decoder = filt_struct{2};
decoder.movement_decoder= filt_struct{3};
decoder.posture_classifier = binnedData.classifiers{2}{1};
decoder.movement_classifier = binnedData.classifiers{2}{2};
decoder_file = strrep(binned_file,'class.mat','perfLDA_velDecoder_1stOrder.mat');
disp(['Saving decoder file as ' decoder_file '...']);
save(decoder_file,'-struct','decoder');

disp('Testing fit...');
disp('Standard Decoder:');
general_pred = predictSignals(decoder.general_decoder,binnedData);
ActualvsOLPred(binnedData,general_pred,0,1);
disp('Hybrid Decoder:');
SD_pred = predictSDSignals(decoder,binnedData,2);
ActualvsOLPred(binnedData,SD_pred,0,1);

disp('Done.')