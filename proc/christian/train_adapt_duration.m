function [vaf,R2,preds] = train_adapt_duration(train_data,test_data,train_duration)

if any(train_duration > train_data.timeframe(end)-train_data.timeframe(1)+1)
    error('training time exceed duration of data');
end

num_iter = length(train_duration);

[num_pts,num_out]  = size(test_data.cursorposbin);
% [num_pts,num_out]  = size(test_data.emgdatabin);

vaf   = nan(num_iter,num_out);
R2    = nan(num_iter,num_out);
preds = nan(num_pts, num_out, num_iter);

params.adapt_params.LR = 5e-7;
params.n_neurons = size(train_data.neuronIDs,1);
params.neuronIDs = train_data.neuronIDs;
% params.mode = 'direct';
params.mode = 'emg_cascade';
E2F = E2F_default;

for i = 1:num_iter
    
    [temp_train_data,~] = splitBinnedData(train_data,train_duration(i),train_data.timeframe(end));
    
    %% use adaptive decoder training
    N2E = adapt_offline(temp_train_data,params);
    [vaf(i,:),R2(i,:),preds(:,:,i)] = plot_predsF(test_data,{N2E;E2F},params.mode);

    %% use optimal decoders
%     H = filMIMO4(temp_train_data.spikeratedata,temp_train_data.cursorposbin,10,1,1);
%     preds(:,:,i) = predMIMOCE3(test_data.spikeratedata,H);
%     R2(i,:)  = CalculateR2(preds(:,:,i),test_data.cursorposbin);
%     vaf(i,:) = calc_vaf(preds(:,:,i),test_data.cursorposbin);
    %% use optimal decoders, predict EMGs
%     H = filMIMO4(temp_train_data.spikeratedata,temp_train_data.emgdatabin,10,1,1);
%     preds(:,:,i) = predMIMOCE3(test_data.spikeratedata,H);
%     R2(i,:)  = CalculateR2(preds(:,:,i),test_data.emgdatabin);
%     vaf(i,:) = calc_vaf(preds(:,:,i),test_data.emgdatabin);
end
    

