% function [vaf] = optimize_lambda(traindata,testdata,varargin)
function [vaf,R2,decoders,preds,iter_params] = optimize_lambda2(E2F,optimdata,varargin)
% varargin = {}
L1     =  0;
L2     = [1];
LR     = [5e-5 1e-5 5e-6 1e-6 5e-7 1e-7 5e-8];

emg_vec    = [1:13];
pos_vec    = [1 2];

if nargin>2 emg_vec   =varargin{1};end
if nargin>3 pos_vec   =varargin{2};end
if nargin>4 lambda    =varargin{3};end
if nargin>5 neuronIDs =varargin{4};end
if nargin>6 numlags   =varargin{5};end

test_ins   = optimdata.spikeratedata;
test_outs = [optimdata.emgdatabin(:,emg_vec) optimdata.cursorposbin(:,pos_vec)];

n_iter = length(L1)*length(L2)*length(LR);
iter_params = nan(n_iter,3);
n_outs = length(emg_vec)+length(pos_vec);
n_tbins= size(test_ins,1);
vaf    = nan(n_iter,n_outs);
R2     = nan(n_iter,n_outs);
preds  = nan(n_tbins,n_outs,n_iter);
decoders = cell(1,n_iter);

iter = 0;
time_rem = 100*n_iter; % 100 sec per training.
tic;
%% iterate through parameters L1, L2 regul + LR
for l1 = 1:length(L1);
    for l2 = 1:length(L2)
        for lr = 1:length(LR)
            iter = iter+1;
            iter_params(iter,:) = [L1(l1) L2(l2) LR(lr)];
            fprintf('Training Iteration %d of %d\n',iter,n_iter);
            fprintf('Time Remaining ~ %.1f min\n',time_rem/60);
            params.lambda = [L1(l1) L2(l2)];
            params.LR     = LR(lr);
            N2E = train_offline_decoder('Spike',params);
            decoders{iter} = N2E;
            %     preds= predMIMOCE3(test_ins,W(:,:,i),numlags);
            predsE = sigmoid(predMIMOCE3(test_ins,N2E.H),'direct');
            %             predsF = predMIMOCE3(sigmoid(predsE,'direct'),E2F.H);
            predsF = predMIMOCE3(predsE,E2F.H);
            preds(:,:,iter) = [predsE predsF];
            vaf(iter,:) = 1 - sum( (preds(:,:,iter)-test_outs).^2 ) ./ sum( (test_outs - repmat(mean(test_outs),size(test_outs,1),1)).^2 );
            R2(iter,:)  = CalculateR2(preds(:,:,iter),test_outs);
            time_rem = (toc/iter)*(n_iter-iter);
        end
    end
end


% %%%%-----------
% for la = 1:length(lambda)
%         predsE = predMIMOCE3(test_ins,decoders{la}.H);
%         predsF = predMIMOCE3(sigmoid(predsE,'direct'),E2F.H);
%         preds = [predsE predsF];
%         vaf(la,:) = 1 - sum( (preds-test_outs).^2 ) ./ sum( (test_outs - repmat(mean(test_outs),size(test_outs,1),1)).^2 );
%         R2(la,:)  = CalculateR2(preds,test_outs);
% end