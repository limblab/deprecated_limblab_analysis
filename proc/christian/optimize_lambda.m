% function [vaf] = optimize_lambda(traindata,testdata,varargin)
function [vaf,R2,decoders,preds,iter_params] = optimize_lambda(E2F,testdata,varargin)
% varargin = {emg_vec,pos_vec,lambda,neuronIDs,numlags}

lambda     = [0 0.5 1 4 20];
% lambda     = 1;
LR         = [1e-6 1e-7 1e-8 1e-9];
% LR         = 1e-6;
emg_vec    = [1:9];
pos_vec    = [1 2];

if nargin>2 emg_vec   =varargin{1};end
if nargin>3 pos_vec   =varargin{2};end
if nargin>4 lambda    =varargin{3};end
if nargin>5 neuronIDs =varargin{4};end
if nargin>6 numlags   =varargin{5};end

test_ins   = testdata.spikeratedata;
test_outs = [testdata.emgdatabin(:,emg_vec) testdata.cursorposbin(:,pos_vec)];

n_iter = length(lambda)^2*length(LR);
iter_params = nan(n_iter,4);
n_outs = length(emg_vec)+length(pos_vec);
n_tbins= size(test_ins,1);
vaf    = nan(n_iter,n_outs);
R2     = nan(n_iter,n_outs);
preds  = nan(n_tbins,n_outs,n_iter);
% W      = nan(1+size(neuronIDs,1)*numlags,n_outs,n_iter);
decoders = cell(1,n_iter);

iter = 0;
l1 = 0;
for l2 = 1:length(lambda)
    for l3 = 1:length(lambda)
        for lr = 1:length(LR)
            iter = iter+1;
            iter_params(iter,:) = [l1 lambda(l2) lambda(l3) LR(lr)];
            fprintf('Training Iteration %d of %d\n',iter,n_iter);
        %     W(:,:,i) = train_decoder(train_ins,train_outs,numlags,lambda(i));
            params.lambda = [l1 lambda(l2) lambda(l3)];
            params.LR     = LR(lr);
            N2E = train_offline_decoder('Jango',params);
            decoders{iter} = N2E;
        %     preds= predMIMOCE3(test_ins,W(:,:,i),numlags);
            predsE = predMIMOCE3(test_ins,N2E.H);
            predsF = predMIMOCE3(sigmoid(predsE,'direct'),E2F.H);
            preds(:,:,iter) = [predsE predsF];
            vaf(iter,:) = 1 - sum( (preds(:,:,iter)-test_outs).^2 ) ./ sum( (test_outs - repmat(mean(test_outs),size(test_outs,1),1)).^2 );
            R2(iter,:)  = CalculateR2(preds(:,:,iter),test_outs);
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