function [vaf,W] = optimize_lambda(traindata,testdata,varargin)
% varargin = {emg_vec,pos_vec,lambda,neuronIDs,numlags}

lambda     = [0.001 0.01 0.1 1 10];
neuronIDs  = [ (1:96)' zeros(96,1)];
emg_vec    = [];
pos_vec    = [1 2];
numlags    = 10;

if nargin>2 emg_vec=varargin{1};end
if nargin>3 pos_vec=varargin{2};end
if nargin>4 lambda=varargin{3};end
if nargin>5 neuronIDs=varargin{4};end
if nargin>6 numlags=varargin{5};end

n_iter = length(lambda);
n_outs = length(emg_vec)+length(pos_vec);
vaf    = nan(n_iter,n_outs);
W      = nan(1+size(neuronIDs,1)*numlags,n_outs,n_iter);

train_ins  = get_spikes_from_neuronIDs(traindata,neuronIDs);
train_outs = [traindata.emgdatabin(:,emg_vec) traindata.cursorposbin(:,pos_vec)];
test_ins   = get_spikes_from_neuronIDs(testdata,neuronIDs);
test_outs  = [testdata.emgdatabin(:,emg_vec) testdata.cursorposbin(:,pos_vec)];

for i = 1:n_iter
    W(:,:,i) = train_decoder(train_ins,train_outs,numlags,lambda(i));
    preds= predMIMOCE2(test_ins,W(:,:,i),numlags);
    vaf(i,:) = 1 - sum( (preds-test_outs).^2 ) ./ sum( (test_outs - repmat(mean(test_outs),size(test_outs,1),1)).^2 );
end