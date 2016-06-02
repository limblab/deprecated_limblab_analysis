% load(['\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\User_folders\'...
%     'Stephanie\Data Analysis\Generalizability\Jango\05-15-15s\HybridData_Jango_051515.mat'])

folder_location = ['\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\User_folders\'...
    'Stephanie\Data Analysis\Generalizability\Jango\07-24-14s\'];
filename = 'HybridData_Jango_072414.mat';

% folder_location = ['\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\User_folders\'...
%     'Stephanie\Data Analysis\Generalizability\Jango\05-15-15s\'];
% filename = 'HybridData_Jango_051515.mat';

load([folder_location filename]);

sqrt_fr_iso = sqrt(IsoBinned.spikeratedata);
sqrt_fr_wm = sqrt(WmBinned.spikeratedata);
sqrt_fr_spr = sqrt(SprBinned.spikeratedata);

behavior_str = {'Iso','Wm','Spr'};

train_test_comb(:,1) = reshape([1 1 1;2 2 2;3 3 3],[],1);
train_test_comb(:,2) = reshape([1 1 1;2 2 2;3 3 3]',[],1);

[b,a] = butter(4,5/(20/2));
num_boot = 50;

figure
for iComb = 1:length(train_test_comb)
    if train_test_comb(iComb,1) == 1
        train_data = sqrt_fr_iso;
    elseif train_test_comb(iComb,1) == 2
        train_data = sqrt_fr_wm;
    elseif train_test_comb(iComb,1) == 3
        train_data = sqrt_fr_spr;
    end
    if train_test_comb(iComb,2) == 1
        test_data = sqrt_fr_iso;
    elseif train_test_comb(iComb,2) == 2
        test_data = sqrt_fr_wm;
    elseif train_test_comb(iComb,2) == 3
        test_data = sqrt_fr_spr;
    end
    
    train_data = filtfilt(b,a,train_data);
    test_data = filtfilt(b,a,test_data);
    if mod(size(train_data,2),2)
        train_data = train_data(:,1:end-1);
        test_data = test_data(:,1:end-1);
    end
    num_channels = size(train_data,2);
    
    train_data = train_data(1:min(size(train_data,1),size(test_data,1)),:);
    test_data = test_data(1:min(size(train_data,1),size(test_data,1)),:);
    if mod(size(train_data,1),2)
        train_data(end,:) = [];
        test_data(end,:) = [];
    end  
    num_datapoints = size(train_data,1);
    
    
    %%    
    % r2 = zeros(num_boot,length(test_channels));
    r2 = [];
    for iBoot = 1:num_boot
        iBoot
        chan_rand_perm = randperm(num_channels);
        train_channels = chan_rand_perm(1:(num_channels/2));
        test_channels = setxor(1:num_channels,train_channels);
        time_rand_perm = randperm(num_datapoints);
        
        train_points = time_rand_perm(1:end/2);
        test_points = setxor(1:num_datapoints,train_points);

        [coeff,score,latent,tsquared,explained,mu] = pca(train_data(train_points,train_channels));
        
        A = train_data(train_points,test_channels);
        B = score;
        x = A\B;
        
        pred_score = test_data(test_points,test_channels)*x;
        [coeff_test,actual_score,~] = pca(test_data(test_points,test_channels));
        
        zscore_actual = zscore(actual_score);
        zscore_pred = zscore(pred_score);
        for iComp1 = 1:length(test_channels)
            for iComp2 = 1:length(test_channels)
                min_error = [];
                min_error(1) = sum(abs(zscore_actual(:,iComp1) +...
                    zscore_pred(:,iComp2)));
                min_error(2) = sum(abs(-zscore_actual(:,iComp1) +...
                    zscore_pred(:,iComp2)));
                min_error(3) = sum(abs(zscore_actual(:,iComp1) -...
                    zscore_pred(:,iComp2)));
                min_error(4) = sum(abs(-zscore_actual(:,iComp1) -...
                    zscore_pred(:,iComp2)));
                score_diff(iComp1,iComp2) = min(min_error);
            end
        end
        
        min_idx = [];
        for iComp1 = 1:length(test_channels)
            [min_score,min_idx(iComp1)] = min(score_diff(iComp1,:));
            score_diff(:,min_idx(iComp1)) = inf;
        end
        pred_score = pred_score(:,min_idx);
        
        for iComp = 1:length(test_channels)
            temp = corrcoef(pred_score(:,iComp),actual_score(:,iComp)).^2;
            r2(iBoot,iComp) = temp(2);
        end
    end
    toc
    
    %%
%     figure;
    subplot(3,3,iComb)
    % plot(r2','Color',[.5 .5 1])
    hold on
    errorarea(1:length(test_channels),mean(r2),std(r2),'b',0.5);
    plot(mean(r2),'b','LineWidth',3)
    ylim([0 1])
    if train_test_comb(iComb,2) == 1
        title({['Training: ' behavior_str{train_test_comb(iComb,1)}];...
            'Predicting PCs from firing rates'})
    end
    if train_test_comb(iComb,1) == 1
        ylabel({['Testing: ' behavior_str{train_test_comb(iComb,2)}],...
            'R^2 between predicted and','actual PC'})
    end
    if train_test_comb(iComb,2) == 3
        xlabel('Principal component')
    end
    xlim([1 46])
    drawnow
end

add_filename_to_figures(gcf,filename)