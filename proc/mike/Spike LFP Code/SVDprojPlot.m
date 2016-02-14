% plot SVD projection results
[FileList, DateNames] = CalcDecoderAge(DateFormNames, DecoderStartDate)
[R2_para_X R2_para_Y DayNames] = DayAverage(R2_para_All(:,:,1), R2_para_All(:,:,2), FileList(:,1), FileList(:,2));
[R2_perp_X R2_perp_Y DayNames] = DayAverage(R2_perp_All(:,:,1), R2_perp_All(:,:,2), FileList(:,1), FileList(:,2));

figure
plot(nanmean(R2_para_Y))
hold on;
plot(nanmean(R2_perp_Y),'r')
title('Y-Vel R^2 using Alphas as separate inputs')
xlabel('Files')
ylabel('R^2')

CV_para_all = std(nanmean(R2_para_Y))/mean(nanmean(R2_para_Y))
CV_perp_all = std(nanmean(R2_perp_Y))/mean(nanmean(R2_perp_Y))

legend(['Alpha 1:2 (Fano Factor = ',num2str(FF_para_all),')'],['Alpha 3:n (Fano Factor = ',num2str(FF_perp_all),')'])
ylim([0.25 1])
ah = findobj(gca,'TickDirMode','auto')

set(ah,'Box','off')
set(ah,'TickLength',[0,0])

figure;
plot(nanmean(R2_para_X(:,:,1),1))
hold on;
plot(nanmean(R2_perp_X(:,:,1),1),'r')
title('X-Vel R^2 using Alphas as separate inputs')
xlabel('Files')
ylabel('R^2')

FF_para_all = var(nanmean(R2_para_All(:,:,1)))/mean(nanmean(R2_para_All(:,:,1)));
FF_perp_all = var(nanmean(R2_perp_All(:,:,1)))/mean(nanmean(R2_perp_All(:,:,1)));

%% For rand alpha analysis
R2_2randMAT = cell2mat(R2_2rand);
R2_2randVect = reshape(R2_2randMAT,size(R2_2randMAT,1)*size(R2_2randMAT,2)*size(R2_2randMAT,3),1);
figure
hist(R2_2randVect)

R2_n_minus2_randMAT = cell2mat(R2_n_minus2_rand);
R2_n_minus2_randVECT = reshape(R2_n_minus2_randMAT,size(R2_n_minus2_randMAT,1)*size(R2_n_minus2_randMAT,2)*size(R2_n_minus2_randMAT,3),1);
figure
hist(R2_n_minus2_randVECT)

%% PCA analysis code

[coeff,score, latent] = princomp(zscore(x));
figure; plot(cumsum(latent)/sum(latent),'o')
xlabel('PC #')
ylabel('Cumulative Sum of Variance')

% N_2_FF = 
% N_Minus2_FF =

%% Code to pull data off figs and run stats

Spike = median(get(gco,'YData'))
Spike(2) = std(get(gco,'YData'))/sqrt(length(get(gco,'YData')))

LFP = nanmedian(get(gco,'YData'))
LFP(2) = nanstd(get(gco,'YData'))/sqrt(length(get(gco,'YData')))

LFPs = get(gco,'YData')
Spikes = get(gco,'YData')
p = ranksum(LFPs,Spikes)

%% other stuff
figure; imagesc(nanmean(R2_para_perp_AllLag{1}(1:150,:),3))

title('X-Vel Alpha_n Decoder Performance')
xlabel('Files')
ylabel('alpha_n')

figure; imagesc(manmean(R2_para_perp_AllLag{2},3))

title('Y-Vel Alpha_n Decoder Performance')
xlabel('Files')
ylabel('alpha_n')

figure; plot(var(mean(R2_para_perp_AllLag{1},3),0,2)./mean(mean(R2_para_perp_AllLag{1},3),2))
xlabel('Alpha #')
ylabel('Fano Factor')
figure; plot(var(mean(R2_para_perp_AllLag{2},3),0,2)./mean(mean(R2_para_perp_AllLag{2},3),2))
xlabel('Alpha #')
ylabel('Fano Factor')


Si = 2; 
Ei = 6;
% R^2 performance for alpha 1
R2_para_AllLag1_Mean_X = nanmean(R2_para_AllLag1(Si:Ei,:,1));
R2_para_AllLag1_Mean_Y = nanmean(R2_para_AllLag1(Si:Ei,:,2));
R2_para_AllLag_Mean_X_NoZ = R2_para_AllLag1_Mean_X(R2_para_AllLag1_Mean_X ~= 0);
R2_para_AllLag_Mean_Y_NoZ = R2_para_AllLag1_Mean_Y(R2_para_AllLag1_Mean_Y ~= 0);

%R^2 performance for alpha 2 
R2_para_AllLag2_Mean_X = nanmean(R2_para_AllLag2(Si:Ei,:,1));
R2_para_AllLag2_Mean_Y = nanmean(R2_para_AllLag2(Si:Ei,:,2));
R2_para_AllLag2_Mean_X_NoZ = R2_para_AllLag2_Mean_X(R2_para_AllLag2_Mean_X ~= 0);
R2_para_AllLag2_Mean_Y_NoZ = R2_para_AllLag2_Mean_Y(R2_para_AllLag2_Mean_Y ~= 0);

% R^2 performance for alpha 1 + alpha 2
R2_para_AllLag3_Mean_X = nanmean(R2_para_AllLag3(Si:Ei,:,1));
R2_para_AllLag3_Mean_Y = nanmean(R2_para_AllLag3(Si:Ei,:,2));
R2_para_AllLag3_Mean_X_NoZ = R2_para_AllLag3_Mean_X(R2_para_AllLag3_Mean_X ~= 0);
R2_para_AllLag3_Mean_Y_NoZ = R2_para_AllLag3_Mean_Y(R2_para_AllLag3_Mean_Y ~= 0);

% R^2 performance for alpha 1 + alpha 2
R2_para_AllLag4_Mean_X = nanmean(R2_para_AllLag4(Si:Ei,:,1));
R2_para_AllLag4_Mean_Y = nanmean(R2_para_AllLag4(Si:Ei,:,2));
R2_para_AllLag4_Mean_X_NoZ = R2_para_AllLag4_Mean_X(R2_para_AllLag4_Mean_X ~= 0);
R2_para_AllLag4_Mean_Y_NoZ = R2_para_AllLag4_Mean_Y(R2_para_AllLag4_Mean_Y ~= 0);

% R^2 performance for n_perp
R2_perp_AllLag_Mean_X = nanmean(R2_perp_AllLag(:,:,1));
R2_perp_AllLag_Mean_X_NoZ = R2_perp_AllLag_Mean_X(R2_perp_AllLag_Mean_X ~= 0);

R2_perp_AllLag_Mean_X = nanmean(R2_perp_AllLag(Si:Ei,:,1));
R2_perp_AllLag_Mean_Y = nanmean(R2_perp_AllLag(Si:Ei,:,2));
R2_perp_AllLag_Mean_X_NoZ = R2_perp_AllLag_Mean_X(R2_perp_AllLag_Mean_X ~= 0);
R2_perp_AllLag_Mean_Y_NoZ = R2_perp_AllLag_Mean_Y(R2_perp_AllLag_Mean_Y ~= 0);

% Now do a day average
[FileList, DateNames] = CalcDecoderAge(DateFormNames, DecoderStartDate)
[R2_para1_DayAvg_X R2_para1_DayAvg_Y DayNames] = DayAverage(R2_para_AllLag1_Mean_X, R2_para_AllLag1_Mean_Y, FileList(:,1), FileList(:,2));
[R2_para2_DayAvg_X R2_para2_DayAvg_Y DayNames] = DayAverage(R2_para_AllLag2_Mean_X, R2_para_AllLag2_Mean_Y, FileList(:,1), FileList(:,2));
[R2_para3_DayAvg_X R2_para3_DayAvg_Y DayNames] = DayAverage(R2_para_AllLag3_Mean_X, R2_para_AllLag3_Mean_Y, FileList(:,1), FileList(:,2));
[R2_para4_DayAvg_X R2_para4_DayAvg_Y DayNames] = DayAverage(R2_para_AllLag4_Mean_X, R2_para_AllLag4_Mean_Y, FileList(:,1), FileList(:,2));

[R2_perp_DayAvg_X R2_perp_DayAvg_Y DayNames] = DayAverage(R2_perp_AllLag_Mean_X, R2_perp_AllLag_Mean_Y, FileList(:,1), FileList(:,2))

figure
plot(R2_para1_DayAvg_X,'b')
hold on 
plot(R2_perp_DayAvg_X','b--')
plot(R2_para1_DayAvg_Y','r')
plot(R2_perp_DayAvg_Y','r--')
title('Alpha 1 X and Y velocity R^2')
legend('X Para','X Perp','Y Para','Y Perp')
ylabel('R^2')
xlabel('Days')

figure
plot(R2_para2_DayAvg_X,'b')
hold on 
plot(R2_perp_DayAvg_X','b--')
plot(R2_para2_DayAvg_Y','r')
plot(R2_perp_DayAvg_Y','r--')
title('Alpha 2 X and Y velocity R^2')
legend('X Para','X Perp','Y Para','Y Perp')
ylabel('R^2')
xlabel('Days')

figure
plot(R2_para3_DayAvg_X,'b')
hold on 
plot(R2_perp_DayAvg_X','b--')
plot(R2_para3_DayAvg_Y','r')
plot(R2_perp_DayAvg_Y','r--')
title('Alpha 1 + Alpha 2 X and Y velocity R^2')
legend('X Para','X Perp','Y Para','Y Perp')
ylabel('R^2')
xlabel('Days')

figure
plot(R2_para4_DayAvg_X,'b')
hold on 
plot(R2_perp_DayAvg_X','b--')
plot(R2_para4_DayAvg_Y','r')
plot(R2_perp_DayAvg_Y','r--')
title('Alpha 1 - Alpha 2 X and Y velocity R^2')
legend('X Para','X Perp','Y Para','Y Perp')
ylabel('R^2')
xlabel('Days')

[FileList, DateNames] = CalcDecoderAge(FileList, DecoderStartDate)
[r_map,r_map_mean, rho, pval, f, x] = CorrCoeffMap(R2_para(:,R2_para_AllLag1_Mean ~= 0,1),1,FileList(R2_para_AllLag1_Mean ~= 0,2))

[r_map,r_map_mean, rho, pval, f, x] = CorrCoeffMap(R2_perp(:,R2_perp_AllLag_Mean ~= 0,1),1,FileList(R2_perp_AllLag_Mean ~= 0,2))

        