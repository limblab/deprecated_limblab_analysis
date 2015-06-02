% function [vaf] = optimize_lambda(traindata,testdata,varargin)
function [vaf,R2,decoders,preds,LR] = optimize_LR(E2F,train_data,optim_data,varargin)
% % varargin = {}
% LR     = [4e-6 2e-6 1e-6 5e-7 2.5e-7 1.25e-7 .625e-7];
delay  = 0.5;
LR = 5e-7;
n_iter = length(LR);


% LR     = 5e-7;
% delay  = [0 100 300 500 550 600 650 700 1000]/1000;
%  n_iter = length(delay);


test_ins   = optim_data.spikeratedata;
test_outs  = optim_data.cursorposbin;

n_outs = size(test_outs,2);
n_tbins= size(test_ins,1);
vaf    = nan(n_iter,n_outs);
R2     = nan(n_iter,n_outs);
preds  = nan(n_tbins,n_outs,n_iter);
decoders = cell(n_iter,2);

% params.mode = 'direct'; 
params.mode = 'emg_cascade'; 

iter = 0;
time_rem = 100*n_iter; % ~100 sec per training.
tic;
%% iterate through parameters LR

for i = 1:n_iter
    iter = iter+1;

    fprintf('Training Iteration %d of %d\n',iter,n_iter);
    fprintf('Time Remaining ~ %.1f min\n',time_rem/60);
    
    params.adapt_params.LR     = LR(i);
    params.adapt_params.delay  = delay;
%     params.adapt_params.LR     = LR;
%     params.adapt_params.delay  = delay(i);

    neuron_dec = adapt_offline(train_data,params);
    decoders{iter,1} = neuron_dec;

    if strcmp(params.mode,'emg_cascade')
        decoders{iter,2} = E2F;
    end
        
    [vaf(iter,:),R2(iter,:),preds(:,:,iter)] = plot_predsF(optim_data,decoders(iter,:),params.mode,varargin{:});

    time_rem = (toc/iter)*(n_iter-iter);
    fprintf('VAF:\t%.2f\t%.2f\nR^2\t%.2f\t%.2f\n',vaf(iter,1),vaf(iter,2),R2(iter,1),R2(iter,2));
end

% LR
figure;
mv = mean(vaf,2);
semilogx(LR,vaf,'o-');
pretty_fig(gca)
hold on;
semilogx(LR,mv,'ko--');
xlim([5e-8 5e-6])
ylim([0 1])
ylabel('VAF');
legend('Fx','Fy','mean');
xlabel('Learning Rate');
% 
% % Delay
% figure;
% mv = mean(vaf,2);
% plot(delay,vaf,'o-');
% pretty_fig(gca)
% hold on;
% plot(delay,mv,'ko--');
% xlim([0 1])
% ylim([-0.3 1])
% ylabel('VAF');
% legend('Fx','Fy','mean');
% xlabel('Delay');

title('Jango\_20140707')

% 
% % Delay
% figure;
% mv = mean(R2,2);
% plot(delay,R2,'o-');
% pretty_fig(gca)
% hold on;
% plot(delay,mv,'ko--');
% xlim([0 1])
% ylim([-0.3 1])
% ylabel('R2');
% legend('Fx','Fy','mean');
% xlabel('Delay');
% title('Kevin\_20150222')