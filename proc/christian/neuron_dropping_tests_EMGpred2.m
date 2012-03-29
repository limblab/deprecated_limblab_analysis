%% Predict data using randomized unit dropping and permutation
function [res]=neuron_dropping_tests_EMGpred3(filter, TestData, NeuronIDs,pctDrop,pctPerm,DP_period,EMGpatterns, initType,NumIter,foldlength,Adapt)


%% Parameters
% Adapt.LR = 1e-7; % Learning Rate
% Adapt.Lag = 10; % Adaptation window (0.5 sec before reward and Go cues)
% Adapt.EMGpatterns = EMGpatterns; %Expected EMG at reward and Go cues
% Adapt.Enable = true;
% Adapt.Period = 1; % number of rewards and go cues (combined) before each Adaptation steps

%% variables to store results
R2ff = cell(1,NumIter); %fixed decoder, no drop/perm (fixed fixed)
R2f = cell(1,NumIter);  %fixed decoder, w/ drops and perm
R2a = cell(1,NumIter);  %adapt decoder, w/ drops and perm
R2af = cell(1,NumIter); %adapt decoder, no drop/perm (adapt fixed)
Neurons = cell(1,NumIter);
H = cell(2,NumIter);
Hd= cell(2,NumIter);

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
    
    TestData_d = TestData;
    H{1,k}  = filter_adapt.H;
    Hd{1,k} = filter_adapt_d.H;
    dropped_units = [];
    
    %times at which to drop and permute units
    DP_bins = DP_period:DP_period:numpts;
    
    % Permute then drop units
    for i = 1:length(DP_bins)
        % 1- permute units
            DPData = TestData_d;
            DPData.spikeratedata = TestData.spikeratedata(DP_bins(i):end,:);
            DPData = rand_perm_units(DPData,pctPerm);
        % 2-drop units (nul firing rate from DP_bins until end of data)
            [DPData, dropped_units] = rand_null_unit(DPData,pctDrop,dropped_units);
            TestData_d.spikeratedata(DP_bins(i):end,:) = DPData.spikeratedata;
    end
            
    %% 5- Make predictions
    %Fixed Model, no drop or permutation
    [R2ff{1,k}] = PeriodicR2(filter,TestData,foldlength);

    %Adaptive algorithm, no drop or permutation
    [R2af{1,k}, filter_adapt] = PeriodicR2(filter_adapt,TestData,foldlength,Adapt);
    H{2,k} = filter_adapt.H;

    %Fixed Model, with neuron loss
    [R2f{1,k}] = PeriodicR2(filter,TestData_d,foldlength);

    %Adaptive algorithm with neuron loss
    [R2a{1,k}, filter_adapt_d] = PeriodicR2(filter_adapt_d,TestData_d,foldlength,Adapt);
    Hd{2,k} = filter_adapt_d.H;


end

res.R2ff= R2ff;
res.R2f = R2f;
res.R2a = R2a;
res.R2af= R2af;
res.NumLoops = NumLoops;
res.Neurons = Neurons;
res.DroppedUnits = dropped_units;
res.H = H;
res.Hd= Hd;
res.filter = filter;
res.info = struct('PctDrop',pctdrop,'PctPerm',pctperm,'LR',Adapt.LR,'Adapt_Lag',Adapt.Lag,'Adapt_Period',Adapt.Period);

%% Mean

% plot_results(res);


% 
% numpts = size(vertcat(res.R2f{:,1}),1);
% 
% R2fc = zeros(numpts, size(res.R2f{1,1},2),res.NumLoops);
% R2ac = zeros(numpts, size(res.R2a{1,1},2),res.NumLoops);
% R2ffc = zeros(numpts, size(res.R2ff{1,1},2),res.NumLoops);
% 
% for i = 1:res.NumLoops
%     R2fc(:,:,i) = vertcat(res.R2f{:,i});
%     R2ac(:,:,i) = vertcat(res.R2a{:,i});
%     R2ffc(:,:,i) = vertcat(res.R2ff{:,i});
% end
% 
% MR2f = mean(R2fc,3);
% MR2a = mean(R2ac,3);
% MR2ff= mean(R2ffc,3);
% 
% SR2f = std(R2fc,0,3);
% SR2a = std(R2ac,0,3);
% SR2ff= std(R2ffc,0,3);
% 
% Mf = mean(MR2f,2);
% Ma = mean(MR2a,2);
% Mff= mean(MR2ff,2);
% 
% SDf = sqrt(SR2f(:,1).^2+SR2f(:,2).^2)/2;
% SDa = sqrt(SR2a(:,1).^2+SR2a(:,2).^2)/2;
% SDff = sqrt(SR2ff(:,1).^2+SR2ff(:,2).^2)/2;
% 
% y_posf = MR2f(:,2);
% y_posa = MR2a(:,2);
% y_posff = MR2ff(:,2);
% 
% res.MR2a = MR2a;
% res.MR2f = MR2f;
% res.MR2ff= MR2ff;
% 
% %% Plots
% figure;
% hold on;
% numpts = size(res.MR2f,1);
% 
% %calculate SD around mean curve
% x = round([1:numpts numpts:-1:1]);
% yft = Mf+SDf;
% yfb = Mf-SDf;
% yf  = [yft; yfb(end:-1:1)];
% 
% yat = Ma+SDa;
% yab = Ma-SDa;
% ya = [yat; yab(end:-1:1)];
% 
% yfft = Mff+SDff;
% yffb = Mff-SDff;
% yff  = [yfft; yffb(end:-1:1)];
% 
% pink = [255 182 193]./255;
% gray = [112 128 144]./255;
% 
% area(x,yff,'FaceColor',gray,'LineStyle','none');
% area(x,yf,'FaceColor','c','LineStyle','none');
% area(x,ya,'FaceColor',pink,'LineStyle','none');
% hf = plot(1:numpts,Mf,'b.-');
% ha = plot(1:numpts,Ma,'r.-');
% hff = plot(1:numpts,Mff,'k.-');
% legend([hf,ha,hff],'fixed model','adaptive model','fixed no drop/perm');
% title('Mean R^2');
% 
% % plot y_pos only
% figure; hold on;
% x = [1:numpts numpts:-1:1];
% yft = y_posf+SR2f(:,2);
% yfb = y_posf-SR2f(:,2);
% yf  = [yft; yfb(end:-1:1)];
% yat = y_posa+SR2a(:,2);
% yab = y_posa-SR2a(:,2);
% ya = [yat; yab(end:-1:1)];
% yfft = y_posff+SR2ff(:,2);
% yffb = y_posff-SR2ff(:,2);
% yff  = [yfft; yffb(end:-1:1)];
% 
% area(x,yff,'FaceColor',gray,'LineStyle','none');
% area(x,yf,'FaceColor','c','LineStyle','none');
% area(x,ya,'FaceColor',pink,'LineStyle','none');
% hf = plot(1:numpts,y_posf,'b.-');
% ha = plot(1:numpts,y_posa,'r.-');
% hff = plot(1:numpts,y_posff,'k.-');
% legend([hf,ha,hff],'fixed model','adaptive model','fixed no drop/perm');
% title('Y\_pos R^2');












