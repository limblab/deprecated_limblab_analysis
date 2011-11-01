%% Predict data using randomized unit dropping and permutation
function [res]=neuron_dropping_tests_EMGpred(filter, NeuronIDs, pctdrop, pctperm, EMGpatterns, rand)

% pctdrop= [0,0,5,0,5,5,5];
% pctperm= [0,0,5,0,5,5,5];

datapath='C:\Documents and Settings\Christian\Desktop\Adaptation2_new_sort\BinnedData\';

TestFileNames = {[datapath 'Strick_mid_7-9-10_001_ext.mat'] ...
                 [datapath 'Strick_mid_7-9-10_002_ext.mat'] ...
                 [datapath 'Strick_mid_7-10-10_001_ext.mat'] ...
                 [datapath 'Strick_mid_7-10-10_003_ext.mat'] ...
                 [datapath 'Strick_mid_7-11-10_001_ext.mat'] ...
                 [datapath 'Strick_mid_7-12-10_001_ext.mat'] ...
                 [datapath 'Strick_mid_7-13-10_001_ext.mat'] ...
                 };

%                 [datapath 'Strick_mid_7-12-10_001.mat'] ...  
NumTestFiles = length(TestFileNames);

% EMGpatternFile = 'C:\Documents and Settings\Christian\Desktop\Adaptation2_new_sort\WF_EMGpatterns';


%% Parameters
Adapt.LR = 1e-7; % Learning Rate
Adapt.Lag = 0.45;
Adapt.EMGpatterns = EMGpatterns;
Adapt.Enable = true;

foldlength = 60;
NumLoops = 10;
% NumLoops = 1;

% variables to store results
R2ff = cell(NumTestFiles,NumLoops); %fixed decoder, no drop/perm (fixed fixed)
R2f = cell(NumTestFiles,NumLoops);  %fixed decoder, w/ drops and perm
R2a = cell(NumTestFiles,NumLoops);  %adapt decoder, w/ drops and perm
R2af = cell(NumTestFiles,NumLoops); %adapt decoder, no drop/perm (adapt fixed)
Neurons = cell(NumTestFiles,NumLoops);
H = cell(NumTestFiles+1,NumLoops);
Hd= cell(NumTestFiles+1,NumLoops);

%% L:oo:ps
for k = 1:NumLoops
       
    if rand
        %start with a random filter for adaptation
        filter_rand    = randomize_weights(filter);
        filter_adapt   = filter_rand;
        filter_adapt_d = filter_adapt;
    else
        %start with a null filter for adaptation
        filter_rand     = filter;
        filter_adapt    = filter_rand; 
        filter_adapt.H  = zeros(size(filter_adapt.H));
        filter_adapt_d  = filter_adapt;
    end
    
    H{1,k}  = filter_adapt.H;
    Hd{1,k} = filter_adapt_d.H;
    dropped_units = [];
    permuted_units = [];    
    
    for i = 1:NumTestFiles
        
        disp(sprintf('Loop %g, File %g',k,i));

        %% 2- load TestData

        TestData = load(TestFileNames{1,i});
        field_name = fieldnames(TestData);
        TestData = getfield(TestData, field_name{:});
        %use neurons from NeuronIDs only:
        matching_neurons = FindMatchingNeurons(TestData.spikeguide,NeuronIDs);
        if any(~matching_neurons)
            disp(sprintf('Some units in NeuronIDs are not found in file %d, operation aborted',i));
            break;
        else
            TestData.spikeguide = TestData.spikeguide(matching_neurons,:);
            TestData.spikeratedata = TestData.spikeratedata(:,matching_neurons);
        end
        
        TestData_d = TestData; % a copy of TestData to use for neuron permutation and drops
        
        %% 3- switch units
        
        %permute units already permuted in previous files
        if ~isempty(permuted_units)
            [TestData_d] = perm_units(TestData_d, permuted_units);
        end
        
        %permute additional units if pctperm(i) > 0%
        if pctperm(i)
            [TestData_d, permuted_units_new] = rand_perm_units(TestData_d,pctperm(i));
            if ~isempty(permuted_units)
                permuted_units = [permuted_units; permuted_units_new];
            else
                permuted_units = permuted_units_new;
            end
        end
        
        %% 4- drop units
        
        %remove units previously dropped  (day 2 and later)
        if ~isempty(dropped_units)
            [TestData_d] = drop_units(TestData_d, dropped_units);
        end

        %remove pctdrop% additional units
        if pctdrop(i)
            [TestData_d, dropped_units_new] = rand_drop(TestData_d,pctdrop(i));
            if ~isempty(dropped_units)
                dropped_units = [dropped_units; dropped_units_new];
            else
                dropped_units = dropped_units_new;
            end
        end
        
        Neurons{i,k} = spikeguide2neuronIDs(TestData_d.spikeguide);
        
        % 4.5 (Temporary hack): for wrist flexion, use only data from extension trials (targets 8,1 and 2)
        % To conserve neuron history, this function also duplicates and shifts neuron, so
        % use a filter lag of 1 from now on
%         filterLag = 10;
%         TestData_d = splitDataFileWrtTgt(TestData_d,[1 2 8],filterLag);
%         TestData   = splitDataFileWrtTgt(TestData  ,[1 2 8],filterLag);
%         filter_adapt.fillen = 0.05; filter.fillen = 0.05;
        %%% End of Temporaray section
        
        
        %% 5- Make predictions
        %Fixed Model, no drop or permutation
        [R2ff{i,k}, nfold] = mfxval_fixed_model(filter,TestData,foldlength);

        %Adaptive algorithm, no drop or permutation
        [R2af{i,k}, nfold, filter_adapt] = mfxval_fixed_model(filter_adapt,TestData,foldlength,Adapt);
        H{i+1,k} = filter_adapt.H;        

        %Fixed Model, with neuron loss
        [R2f{i,k}, nfold] = mfxval_fixed_model(filter,TestData_d,foldlength);
        
        %Adaptive algorithm with neuron loss
        [R2a{i,k}, nfold, filter_adapt_d] = mfxval_fixed_model(filter_adapt_d,TestData_d,foldlength,Adapt);
        Hd{i+1,k} = filter_adapt_d.H;
        
    end
end

res.R2ff= R2ff;
res.R2f = R2f;
res.R2a = R2a;
res.R2af= R2af;
res.NumLoops = NumLoops;
res.Neurons = Neurons;
res.DroppedUnits = dropped_units;
res.PermUnits = permuted_units;
res.H = H;
res.Hd= Hd;
res.filter = filter;
res.TestFileNames = TestFileNames;
res.info = struct('PctDrop',pctdrop,'PctPerm',pctperm,'LR',Adapt.LR,'Adapt_Lag',Adapt.Lag);

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












