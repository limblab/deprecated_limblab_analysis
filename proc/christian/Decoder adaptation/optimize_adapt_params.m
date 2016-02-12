% function [vaf] = optimize_lambda(traindata,testdata,varargin)
function results = optimize_adapt_params(train_data,optim_data,opt_variable,varargin)

switch opt_variable
    case 'delay'
        if nargin > 3
            delay = varargin{1};
        else
            delay = [0 .2 .4 .5 .55 .6 .65 .7 1];
        end
        n_iter = length(delay);
        LR = 5e-7; params.adapt_params.LR = LR;
    case 'LR'
        if nargin > 3
            LR = varargin{1};
        else
            LR     = [4e-6 2e-6 1e-6 5e-7 2.5e-7 1.25e-7 .625e-7];
        end
        n_iter = length(LR);
        delay = 0.6; params.adapt_params.delay = delay;
end

test_ins   = optim_data.spikeratedata;
test_outs  = optim_data.cursorposbin;

n_outs = size(test_outs,2);
n_tbins= size(test_ins,1);
vaf    = nan(n_iter,n_outs);
R2     = nan(n_iter,n_outs);
mse    = nan(n_iter,1);
predsF = nan(n_tbins,n_outs,n_iter);
decoders = cell(n_iter,2);
figh   = [];

% params.mode = 'direct'; 
params.mode = 'emg_cascade';

if strcmp(params.mode,'emg_cascade')
    E2F = E2F_deRugy_PD;
    predsE = nan(n_tbins,size(E2F.emglabels,2),n_iter);
end

time_rem = 100*n_iter; % ~100 sec per training.
tic;
%% iterate through parameters LR

for iter = 1:n_iter

    fprintf('Training Iteration %d of %d\n',iter,n_iter);
    fprintf('Time Remaining ~ %.1f min\n',time_rem/60);

    switch opt_variable
        case 'delay'
            params.adapt_params.delay  = delay(iter);
        case 'LR'
            params.adapt_params.LR     = LR(iter);
    end
           
    neuron_dec = adapt_offline(train_data,params);
    decoders{iter,1} = neuron_dec;

    if strcmp(params.mode,'emg_cascade')
        decoders{iter,2} = E2F;
    end
    if ~isempty(figh)
        for f = 1:length(figh)
            close(figh(f))
        end
    end
    [vaf(iter,:),R2(iter,:),mse(iter),predsF(:,:,iter),predsE(:,:,iter),figh] = plot_predsF(optim_data,decoders(iter,:),params.mode);

    time_rem = (toc/iter)*(n_iter-iter);
    fprintf('VAF:\t%.2f\t%.2f\nR^2:\t%.2f\t%.2f\nMSE:\t%.1f\n',...
                vaf(iter,1),vaf(iter,2),R2(iter,1),R2(iter,2),mse(iter,1));
end

for f = 1:length(figh)
    close(figh(f))
end

switch opt_variable
    case 'delay'
        figure;
        mv = mean(vaf,2);
        plot(delay,vaf,'o-');
        pretty_fig(gca)
        hold on;
        plot(delay,mv,'ko--');
        xlim([0 1])
        ylim([-0.3 1])
        ylabel('VAF');
        legend('Fx','Fy','mean');
        xlabel('Delay');
        title(['VAF' strrep(train_data.meta.filename,'_','\_')]);
        
        figure;
        plot(delay,mse,'ko-');
        pretty_fig(gca)
        xlim([0 1]);
        ylim([0 50]);
        ylabel('MSE');
        legend('MSE');
        xlabel('Delay');
        title(['MSE' strrep(train_data.meta.filename,'_','\_')]);
    case 'LR'
        figure;
        mv = mean(vaf,2);
        semilogx(LR,vaf,'o-');
        pretty_fig(gca)
        hold on;
        semilogx(LR,mv,'ko--');
        xlim([5e-8 5e-6])
        ylim([-0.3 1])
        ylabel('VAF');
        legend('Fx','Fy','mean');
        xlabel('LR');
        title(['VAF' strrep(train_data.meta.filename,'_','\_')]);
        
        figure;
        semilogx(LR,mse,'ko-');
        pretty_fig(gca)
        xlim([5e-8 5e-6])
        ylim([0 50]);
        ylabel('MSE');
        legend('MSE');
        xlabel('LR');
        title(['MSE' strrep(train_data.meta.filename,'_','\_')]);
end

results = struct(...
    'vaf'       ,vaf,...
    'R2'        ,R2,...
    'mse'       ,mse,...
    'decoders'  ,{decoders},...
    'predsF'    ,predsF,...
    'LR'        ,LR,...
    'delay'     ,delay);
