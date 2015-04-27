% delay = 0:0.05:1;
% delay = [0.05 0.35 0.6 0.8x];
emg_thresh = [0 0.05 0.1 0.15 0.2 0.25 0.3 0.4 0.5];

num_iter = length(emg_thresh);
vaf = nan(num_iter,2);

for i = 1:num_iter;
    
    fprintf('iter %d of %d',i,num_iter);
    
    params.sigmoid = true;
    params.adapt_params.duration = inf;
%     params.adapt_params.delay    = delay(i);
    params.emg_thresh = emg_thresh(i);
    vaf(i,:) = train_adapt_duration(traindata,testdata,60*35,'normal',params)
    
end
    
    