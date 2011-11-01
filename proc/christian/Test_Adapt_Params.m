
function [R2, info] = Test_Adapt_Params()

filter = load('C:\Documents and Settings\Christian\Desktop\SpikeAdapt\SavedFilters\Spike_modelBuilding_tube_10-31-11_002_ComUnits10-31to11-01_EMGDecoder');
field_name = fieldnames(filter);
filter = getfield(filter, field_name{:});

TestData = load('C:\Documents and Settings\Christian\Desktop\SpikeAdapt\concatData_10-31_to_11-01.mat');
field_name = fieldnames(TestData);
TestData = getfield(TestData,field_name{:});

Adapt.Enable = true;
Adapt.LR = 1e-7;
Adapt.Lag = 0.45;
binsize = filter.binsize;
foldlength = 60;
duration = size(TestData.timeframe,1);
nfold = floor(round(binsize*1000)*duration/(1000*foldlength)); % again, because of floating point errors

% Adapt_Lag = 0:0.05:0.15;
% R2 = zeros(nfold,2,length(Adapt_Lag));
Tested_Param = 'LR';
LR = (31.25e-10)*2.^(0:9);
R2 = zeros(nfold,size(filter.outnames,1),length(LR));
MR2 = zeros(length(LR),2);

for i = 1:length(eval(Tested_Param))
    Adapt.LR = LR(i);
    [R2(:,:,i), nfold] = mfxval_fixed_model(filter,TestData,foldlength,Adapt);
    MR2(i,:) = mean(R2(:,:,i));
end

info = struct('LR',LR,'Adapt_Lag',Adapt_Lag,'foldlength',foldlength,'nfold',nfold,'Tested_Param',Tested_Param);

figure;
hold on;
plot(eval(Tested_Param),[MR2 mean(MR2,2)],'.-');
legend(filter.outnames,'average');

end

