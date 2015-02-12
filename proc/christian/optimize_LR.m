% function [vaf] = optimize_lambda(traindata,testdata,varargin)
function [vaf,R2,decoders,preds,LR] = optimize_LR(E2F,train_data,optim_data,varargin)
% varargin = {}
LR     = [3e-6 2e-6 8e-7 6e-7];

test_ins   = optim_data.spikeratedata;
test_outs  = optim_data.cursorposbin;

n_iter = length(LR);
n_outs = size(test_outs,2);
n_tbins= size(test_ins,1);
vaf    = nan(n_iter,n_outs);
R2     = nan(n_iter,n_outs);
preds  = nan(n_tbins,n_outs,n_iter);
decoders = cell(n_iter,2);

params.mode = 'direct';

iter = 0;
time_rem = 100*n_iter; % 100 sec per training.
tic;
%% iterate through parameters L1, L2 regul + LR

for lr = 1:length(LR)
    iter = iter+1;

    fprintf('Training Iteration %d of %d\n',iter,n_iter);
    fprintf('Time Remaining ~ %.1f min\n',time_rem/60);
    
    params.adapt_params.LR     = LR(lr);
    neuron_dec = adapt_offline(train_data,params);
    decoders{iter,1} = neuron_dec;

    if strcmp(params.mode,'emg_cascade')
        decoders{iter} = E2F;
    end
        
%     predsE          = sigmoid(predMIMOCE3(test_ins,N2E.H),'direct');
%     preds(:,:,iter) = predMIMOCE3(predsE,E2F.H);
%     vaf(iter,:) = 1 - sum( (preds(:,:,iter)-test_outs).^2 ) ./ sum( (test_outs - repmat(mean(test_outs),size(test_outs,1),1)).^2 );
%     R2(iter,:)  = CalculateR2(preds(:,:,iter),test_outs);

    [vaf(iter,:),R2(iter,:),preds(:,:,iter)] = plot_predsF(optim_data,decoders(iter),params.mode,varargin);

    time_rem = (toc/iter)*(n_iter-iter);
    fprintf('VAF:\t%.2f\t%.2f\nR^2\t%.2f\t%.2f\n',vaf(iter,1),vaf(iter,2),R2(iter,1),R2(iter,2));
end