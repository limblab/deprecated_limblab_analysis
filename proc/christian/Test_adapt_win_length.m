
%----

filter = load('C:\Documents and Settings\Christian\Desktop\7-9 to 7-13 Adapt\Adaptive Filters\InitialNullFilter.mat');
field_name = fieldnames(filter);
filter = getfield(filter, field_name{:});

Adapt_Enable = true;
LR = 0.0000001;
Adapt_Lag = 0.2:0.05:1;
binsize = filter.binsize;
foldlength = 60;
duration = size(binnedData_conc.timeframe,1);
nfold = floor(round(binsize*1000)*duration/(1000*foldlength)); % again, because of floating point errors

R2 = zeros(nfold,2,length(Adapt_Lag));

Adapt_Lag = 0:0.05:0.15;

for i = 1:length(Adapt_Lag)
    [R2(:,:,i), nfold] = mfxval_fixed_model(filter,binnedData_conc,foldlength,Adapt_Enable,LR,Adapt_Lag(i));
end

