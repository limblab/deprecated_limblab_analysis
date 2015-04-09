% delay = 0:0.05:1;
delay = [0.05 0.35 0.6 0.8x];
num_iter = length(delay);
vaf = nan(num_iter,2);

for i = 1:num_iter;
    
    fprintf('iter %d of %d',i,num_iter);
    
    params.sigmoid = true;
    params.adapt_params.duration = inf;
    params.adapt_params.delay    = delay(i);
    vaf(i,:) = train_adapt_duration(traindata,testdata,900,'normal',params)
    
end
    
    