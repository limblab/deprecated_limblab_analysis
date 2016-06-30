% Model Comparison Example...
opts.TOOLBOX_HOME=pwd;
addpath(genpath(opts.TOOLBOX_HOME));

% Data Model
params = [1 4 90 20 2];

% Fig 7A,B (Constant vs Tuned)
x0 = linspace(0,179,1000);
% True Tuning Curve
tc_func_name = 'circular_gaussian_180'; % or 'constant';
% Models
tc_func_name1 = 'circular_gaussian_180';
tc_func_name2 = 'constant';
noise_model = 'poisson';

%  Fig 7C,D (Direction Selective vs Non-Direction Selective)
% x0 = linspace(0,359,1000);
% % True Tuning Curve
% tc_func_name = 'circular_gaussian_180'; % or 'direction_selective_circular_gaussian';
% % Models
% tc_func_name1 = 'circular_gaussian_180';
% tc_func_name2 = 'direction_selective_circular_gaussian';
% noise_model = 'poisson';

% MCMC parameters
opts.burnin_samples=1000;
opts.num_samples=2000;
opts.sample_period=50;

% Experiment and Trial parameters
nsampvec = 3:1:100;
experimentN = 100;

for j=1:experimentN
    for nsampsidx = 1:length(nsampvec)
        fprintf('%02i>>%02i/%02i...\n',j,nsampsidx,length(nsampvec))

        % Create simulated data
        x = rand(nsampvec(nsampsidx),1)*range(x0);
        v = getTCval(x,tc_func_name,params);
        y = poissrnd(v);

        % Perform sampling
        S1=tc_sample(x,y,tc_func_name1,noise_model,opts);
        S2=tc_sample(x,y,tc_func_name2,noise_model,opts);
        % Maximum likelihood estimation
%         S1=ml_fit(x,y,tc_func_name1,noise_model);
%         S2=ml_fit(x,y,tc_func_name2,noise_model);

        % Plot samples
        figure(1)
        subplot(1,2,1);
        plotMCMCres(S1,x0,x,y,tc_func_name1);
%         plot(x0,getTCval(x0,tc_func_name1,getMCMCparams(S1,1)));
        hold on; plot(x,y,'k.'); hold off;
        title(strrep(tc_func_name1,'_',' '));
        subplot(1,2,2);
        plotMCMCres(S2,x0,x,y,tc_func_name2);
%         plot(x0,getTCval(x0,tc_func_name2,getMCMCparams(S2,1)));
        hold on; plot(x,y,'k.'); hold off;
        title(strrep(tc_func_name2,'_',' '));

        % Compute likelihood ratio and bayes factor
        maxllhd(nsampsidx,j,1) = max(S1.log_llhd);
        maxllhd(nsampsidx,j,2) = max(S2.log_llhd);
        llhdR(nsampsidx,j) = exp(maxllhd(nsampsidx,j,1)-maxllhd(nsampsidx,j,2));
        bayeF(nsampsidx,j) = compute_bf(S1,S2);
        
        % Save parameters...
        [b,idx] = max(S1.log_llhd);
        MLEvals{1}(j,nsampsidx,:) = getMCMCparams(S1,idx);
        MLEvals{2}(j,nsampsidx,:) = getMCMCparams(S2,idx);
        BEEvals{1}(j,nsampsidx,:) = getMCMCparams(S1,0);
        BEEvals{2}(j,nsampsidx,:) = getMCMCparams(S2,0);
                
%         Plot likelihood ratio and Bayes Factor
        figure(2)
        subplot(1,2,1)
        boxplot(log(llhdR(1:nsampsidx,:)'))
        hold on; line([xlim],[0 0]); hold off
        title('Likelihood Ratio')
        subplot(1,2,2)
        boxplot(log(bayeF(1:nsampsidx,:)'))
        hold on; line([xlim],[0 0]); hold off
        title('Bayes Factor')
    end
end

%%

for i=1:length(S1.log_llhd)
    hmi(i,1) = harmmean(S1.log_llhd(1:i));
    hmi(i,2) = harmmean(S2.log_llhd(1:i));
    bfi(i) = compute_bf(S1,S2,i);
end

%% AIC/BIC

for i=1:size(mle,1)
    for j=1:size(mle,2)
        AICR(i,j) = (2*4 - 2*mle(i,j,1))./(2*5 - 2*mle(i,j,2));
        BICR(i,j) = (4*log(nsampvec(i)) - 2*mle(i,j,1))./(5*log(nsampvec(i)) - 2*mle(i,j,2));
%         AICR(i,j) = (2*4 - 2*mle(i,j,1))./(2*1 - 2*mle(i,j,2));
%         BICR(i,j) = (4*log(nsampvec(i)) - 2*mle(i,j,1))./(1*log(nsampvec(i)) - 2*mle(i,j,2));
    end
end

%% Cross-validated llhd...

% calculate llhds
tc_func_name_list = {tc_func_name1,tc_func_name2};
nsampvec = 3:1:100;
for j=1:experimentN
    for nsampsidx = 1:length(nsampvec)
        % Create simulated data
        x = rand(nsampvec(nsampsidx),1)*range(x0);
        v = getTCval(x,tc_func_name,params);
        y = poissrnd(v);
        for i=1:length(MLEvals)
            yhat = getTCval(x,tc_func_name_list{i},squeeze(MLEvals{i}(j,nsampsidx,:))');
            llhdT(nsampsidx,j,i) = -sum(log(yhat).*y - yhat);
        end
    end
end

%% Log_llhd ratio as a fn of trials

clf
nsampvec = 3:1:100;
llhdTR = exp(llhdT(:,:,2)-llhdT(:,:,1));
boxplot(real(log(llhdTR')),'positions',nsampvec,'color',[1 1 1]*0.5,'symbol','w.')
set(gca,'XTick',0:10:max(nsampvec))
line([xlim],[0 0],'Color','k')
labels = cell(0);
for i=0:10:max(nsampvec)
    labels{length(labels)+1} = num2str(i);
end
set(gca,'XTickLabel',labels)
ylabel('log-Ratio')
xlabel('Trials')
ylim([-80 80])

%%

plot(sum(log(llhdTR)>0,2)/size(llhdTR,2),'.')
hold on
plot(sum(log(bayeF)>0,2)/size(bayeF,2),'r.')
hold off
ylim([0 1])

%%
lerr = reshape([0.5; 0.5; sum(log(llhdTR)>0,2)]/size(llhdTR,2),2,[]);
berr = reshape([0.5; sum(log(bayeF)>0,2)]/size(bayeF,2),2,[]);
errorbar(mean(lerr),std(lerr)/sqrt(size(lerr,1)),'.')
hold on
errorbar(mean(berr),std(berr)/sqrt(size(berr,1)),'r.')
hold off
ylim([0 1])

%% Err...

for i=1:size(llhdTR,1)
    err(i) = sum(log(llhdTR(i,:))<0)/size(llhdTR,2);
    errb(i) = sum(log(bayeF(i,:))<0)/size(bayeF,2);
end
% plot((err),'.')
errorbar(mean(reshape([0 err],10,[])),std(reshape([0 err],10,[])),'.')
hold on
errorbar(mean(reshape([0 errb],10,[])),std(reshape([0 errb],10,[])),'r.')
ylim([0 1])
hold off

%% Plotter...

subplot(1,4,1)
boxplot(log(bayeF'),'positions',nsampvec,'color','k','symbol','w.')
subplot(1,4,2)
boxplot(log(llhdR'),'positions',nsampvec,'color',[1 1 1]*0.5,'symbol','w.')
subplot(1,4,3)
boxplot(log(1./AICR'),'positions',nsampvec,'color',[1 0 0]*0.5,'symbol','w.')
subplot(1,4,4)
boxplot(log(1./BICR'),'positions',nsampvec,'color',[0 0 1]*0.5,'symbol','w.')

plotLabels = {'Bayes Factor','Log-Likelihood Ratio','AIC-Ratio','BIC-Ratio'};
for f=1:4
    subplot(1,4,f)
    xlim([0 max(nsampvec)])
    if f<3
%         ylim([-1 1]*8)
%         ylim([-1 1]*80)
%         ylim([-1 1]*5)
        ylim([-1 1]*10)
    else
%         ylim([-1 1]*0.75)
%         ylim([-1 1]*0.75)
        ylim([-1 1]*0.25)
    end
    line([xlim],[0 0],'Color','k')
    set(gca,'XTick',0:10:max(nsampvec))
    labels = cell(0);
    for i=0:10:max(nsampvec)
        labels{length(labels)+1} = num2str(i);
    end
    set(gca,'XTickLabel',labels)
    ylabel('log-Ratio')
    xlabel('Trials')
    title(plotLabels{f})
end


%% Old
clf
boxplot(log(bayeF'),'positions',nsampvec,'color','k','symbol','w.')
hold on
boxplot(log(llhdR'),'positions',nsampvec,'color',[1 1 1]*0.5,'symbol','w.')
hold off

    xlim([0 max(nsampvec)])
    ylim([-5 5])
    line([xlim],[0 0],'Color','k')
    set(gca,'XTick',0:10:max(nsampvec))
    labels = cell(0);
    for i=0:10:max(nsampvec)
        labels{length(labels)+1} = num2str(i);
    end
    set(gca,'XTickLabel',labels)
    ylabel('log-Ratio')
    xlabel('Trials')

%% Plot samps

figure(2)
    subplot(1,2,1)
    plot(x,yjittered,'.k');
    hold on
    plot(x1,y1_samps(1:10:end,:),'b');
    plot(x1,y1_med,'b','linewidth',2);
    plot(x1,y_true,'k','linewidth',3);
    hold off
    xlim([0 360])
%     ylim([0 7])
    box off
    
    subplot(1,2,2)
    plot(x,yjittered,'.k');
    hold on
    plot(x1,y2_samps(1:10:end,:),'r');
    plot(x1,y2_med,'r','linewidth',2);
    plot(x1,y_true,'k','linewidth',3);
    hold off
    xlim([0 360])
%     ylim([0 7])
    box off
    
%%

plot(mean(log(bayeF')),'k')
hold on
plot(mean(log(bayeF'))+std(log(bayeF'))/sqrt(size(bayeF,2)),'k:')
plot(mean(log(bayeF'))-std(log(bayeF'))/sqrt(size(bayeF,2)),'k:')
plot(mean(log(llhdR')),'-','Color',[1 1 1]*0.5)
hold off