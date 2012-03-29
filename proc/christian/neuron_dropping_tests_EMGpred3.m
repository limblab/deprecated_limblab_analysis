%% Predict data using randomized unit dropping and permutation
function [res]=neuron_dropping_tests_EMGpred3(filter,TestData,pctDrop,pctPerm,DP_period,initType,NumIter,foldlength,Adapt)


%% variables to store results
R2ff = cell(1,NumIter); %fixed decoder, no drop/perm (fixed fixed)
R2f  = cell(1,NumIter);  %fixed decoder, w/ drops and perm
R2a  = cell(1,NumIter);  %adapt decoder, w/ drops and perm
R2af = cell(1,NumIter); %adapt decoder, no drop/perm (adapt fixed)
H    = cell(2,NumIter);
Hd   = cell(2,NumIter);

%% L:oo:ps
for k = 1:NumIter
       
    if initType == 1
        %start with a random filter for adaptation
        filter_adapt   = randomize_weights(filter);
        filter_adapt_d = filter_adapt;
    elseif initType == 2
        %start with the linear filterres
        filter_adapt   = filter;
        filter_adapt_d = filter;
    else
        %start with a null filter for adaptation
        filter_adapt    = filter; 
        filter_adapt.H  = zeros(size(filter_adapt.H));
        filter_adapt_d  = filter_adapt;
    end
    
    numPts = length(TestData.timeframe);
    TestData_d = TestData;
    H{1,k}  = filter_adapt.H;
    Hd{1,k} = filter_adapt_d.H;
    dropped_units = [];
    
    %times at which to drop and permute units
    DP_bins = DP_period:DP_period:numPts;
    
    % Permute then drop units
    for i = 1:length(DP_bins)
        % 1- permute units
            DPData = TestData_d;
            DPData.spikeratedata = TestData_d.spikeratedata(DP_bins(i):end,:);
            DPData = rand_perm_units(DPData,pctPerm);
        % 2-drop units (nul firing rate from DP_bins until end of data)
            [DPData, dropped_units] = rand_null_unit(DPData,pctDrop,dropped_units);
            TestData_d.spikeratedata(DP_bins(i):end,:) = DPData.spikeratedata;
    end
    
    disp(sprintf('Iteration %d of %d',k,NumIter));
    disp('Beginning Predictions - ');
    
%     %% 5- Make predictions
%     %Fixed Model, no drop or permutation
%     disp('Predictions for Linear Model, no drop/perm...');
%     [R2ff{1,k}] = PeriodicR2(filter,TestData,foldlength);
% %     disp(['Mean R2 = ' sprintf(' [%.2f]',mean(R2ff{1,k}))]);
% 
%     disp('Predictions for Adaptive Model, no drop/perm...');
%     %Adaptive algorithm, no drop or permutation
%     [R2af{1,k}, filter_adapt] = PeriodicR2(filter_adapt,TestData,foldlength,Adapt);
%     H{2,k} = filter_adapt.H;
%     disp(['Mean R2 = ' sprintf(' [%.2f]',mean(R2af{1,k}))]);
    
    disp('Predictions for Linear Model, with drop/perm...');
    %Fixed Model, with neuron loss
    [R2f{1,k}] = PeriodicR2(filter,TestData_d,foldlength);
    disp(['Mean R2 = ' sprintf(' [%.2f]',mean(R2f{1,k}))]);
    
    disp('Predictions for Adaptive Model, with drop/perm...');
    %Adaptive algorithm with neuron loss
    [R2a{1,k}, filter_adapt_d] = PeriodicR2(filter_adapt_d,TestData_d,foldlength,Adapt);
    Hd{2,k} = filter_adapt_d.H;
    disp(['Mean R2 = ' sprintf(' [%.2f]',mean(R2a{1,k}))]);
    
    disp(sprintf('End of Iteration %d',k));

end

res.R2ff= R2ff;
res.R2f = R2f;
res.R2a = R2a;
res.R2af= R2af;
res.NumIter = NumIter;
res.droppedUnits = dropped_units;
res.H = H;
res.Hd= Hd;
res.filter = filter;
res.info = struct('PctDrop',pctDrop,'PctPerm',pctPerm,'LR',Adapt.LR,'Adapt_Lag',Adapt.Lag,'Adapt_Period',Adapt.Period);
