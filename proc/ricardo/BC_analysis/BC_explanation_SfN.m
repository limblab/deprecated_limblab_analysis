rewards = [5     6    16    23    20    18    18];
fails =  [14    15     2     0     0     1     0];
currents = [0 10 20 30 35 40 45];

responses = rewards./(rewards+fails);
normalized_responses = (responses-min(responses))./(1-min(responses));

response_vector = [ones(rewards(1),1);zeros(fails(1),1)];
current_vector = repmat(currents(1),rewards(1)+fails(1),1);
for iCondition = 2:length(rewards)
    response_vector(end:end+rewards(iCondition)) = 1;
    response_vector(end:end+fails(iCondition)) = 0;
    current_vector(end:end+rewards(iCondition)+fails(iCondition)) = currents(iCondition);
end

fit_func = 'Pmin + (Pmax - Pmin)/(1+exp(beta*(xthr-x)))';
f_sigmoid = fittype(fit_func,'independent','x');
f_opts = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1 0 0.1 20],...
    'MaxFunEvals',10000,'MaxIter',1000,'Lower',[0.3 0 0 0],'Upper',[1 0.7 inf 100]);

sigmoid_vector = fit(current_vector,response_vector,f_sigmoid,f_opts);
sigmoid_vector_conf = confint(sigmoid_vector);
sigmoid_ratios = fit(currents',responses',f_sigmoid,f_opts);
sigmoid_ratios_conf = confint(sigmoid_ratios);
sigmoid_normalized = fit(currents',normalized_responses',f_sigmoid,f_opts);
sigmoid_normalized_conf = confint(sigmoid_normalized);

figure; 
hold on
plot(0:.1:currents(end),sigmoid_vector(0:.1:currents(end)),'b')
plot(0:.1:currents(end),sigmoid_ratios(0:.1:currents(end)),'r')
legend('Fitting all responses','Fitting ratios')
plot(sigmoid_vector_conf(:,4),repmat((sigmoid_vector.Pmax+sigmoid_vector.Pmin)/2,2,1),'b-')
plot(sigmoid_ratios_conf(:,4),repmat((sigmoid_ratios.Pmax+sigmoid_ratios.Pmin)/2,2,1),'r-')
plot(currents,responses,'.k')

%%
figure;
% subplot(3,1,1)
% hold on
% plot(0:.1:currents(end),sigmoid_ratios(0:.1:currents(end)),'k')
% plot(sigmoid_ratios_conf(:,4),repmat((sigmoid_ratios.Pmax+sigmoid_ratios.Pmin)/2,2,1),'k-')
% plot(currents,responses,'.k')
% ylabel('Rewards/Total trials')
% title('Raw responses')
% ylim([0 1])
% xlim([0 max(currents)])
% subplot(3,1,2)
hold on
plot(0:.1:currents(end),sigmoid_ratios(0:.1:currents(end)),'-k','LineWidth',2)
plot(0:.1:currents(end),sigmoid_normalized(0:.1:currents(end)),'-b','LineWidth',2)
legend('Raw responses','Normalized responses','Location','SouthEast')
plot(sigmoid_ratios_conf(:,4),repmat((sigmoid_ratios.Pmax+sigmoid_ratios.Pmin)/2,2,1),'k-','LineWidth',2)
plot(sigmoid_normalized_conf(:,4),repmat((sigmoid_normalized.Pmax+sigmoid_normalized.Pmin)/2,2,1),'b-','LineWidth',2)
plot(currents,responses,'.k','MarkerSize',20)
plot(currents,normalized_responses,'.b','MarkerSize',20)
title('Normalization')
ylim([0 1])
xlim([0 max(currents)])
xlabel('Current (uA)')
ylabel('Probability of detection')
% subplot(3,1,3)
% hold on
% plot(0:.1:currents(end),sigmoid_normalized(0:.1:currents(end)),'b')
% plot(sigmoid_normalized_conf(:,4),repmat((sigmoid_normalized.Pmax+sigmoid_normalized.Pmin)/2,2,1),'b-')
% plot(currents,normalized_responses,'.b')
% xlabel('Current (uA)')
% ylabel('Probability of detection')
% title('Normalized responses')
% ylim([0 1])
% xlim([0 max(currents)])
