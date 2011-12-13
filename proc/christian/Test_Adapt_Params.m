function [R2,MR2,info] = Test_Adapt_Params(filter,TestData,foldlength,Adapt)

EMGpatterns = load('C:\Documents and Settings\Christian\Desktop\SpikeAdapt\EMGPatterns\EMGPatterns_from_concatData_10-31_11-04_2E');
EMGpatterns = EMGpatterns.EMGpatterns; % dah

binsize = filter.binsize;
numEMGs = size(EMGpatterns,2);

duration = size(TestData.timeframe,1);
nfold = floor(round(binsize*1000)*duration/(1000*foldlength)); % again, because of floating point errors

%  Tested_Param = 'LR';
%  ParamValues = (1e-10)*2.^(0:20);

% Tested_Param = 'Period';
% ParamValues = [1 5:5:50];

R2 = zeros(nfold,size(filter.outnames,1),length(ParamValues));
MR2 = zeros(length(ParamValues),numEMGs);

for i = 1:length(ParamValues)
    disp(sprintf('Testing Adapt with %s = %g...',Tested_Param,ParamValues(i)));
%     Adapt.LR = ParamValues(i);
    Adapt.Period = ParamValues(i);
    [R2(:,:,i)] = PeriodicR2(filter,TestData,foldlength,Adapt);
    MR2(i,:) = mean(R2(:,:,i));
    disp(['R2 = ' sprintf(' [%.2f]',MR2(i,:))]);
end

info = struct('LR',Adapt.LR,'Adapt_Lag',Adapt.Lag,'Adapt_Period',Adapt.Period, ...
                'foldlength',foldlength,'Tested_Param',Tested_Param,'Param_Values',ParamValues);

figure;
hold on;
plot(ParamValues,[MR2 mean(MR2,2)],'.-');
legNames = cell(numEMGs,1);
for i=1:size(filter.outnames,1)
    legNames{i} = filter.outnames(i,:);
end
title(sprintf('R2 for different adaptation %s values',Tested_Param));
legend([legNames' {'average'}]);

end

