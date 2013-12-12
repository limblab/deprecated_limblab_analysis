%% save stuff
VAF_unc_rand = VAF_unc;
VAF_con_rand = VAF_con;

%% save stuff
VAF_unc_trained = VAF_unc;
VAF_con_trained = VAF_con;

%% plot stuff
figure
plot(VAF_unc_rand,VAF_con_rand,'b.', VAF_unc_trained,VAF_con_trained,'g.')
grid on
xlabel('Unconstrained Condition R^2')
ylabel 'Joint Constrained Condition R^2'
axis([0 1 0 1])
legend('Randomly Weighted Neurons','Trained Neurons')
title 'R^2 of Firing Rate Regression to Endpoint'