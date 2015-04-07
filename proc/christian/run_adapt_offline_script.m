

dataset = 'Jango\_20150127';

train_duration = 60*[5 7.5 10 15 20];

% conditions = {'normal','supervised','N2F_target'};%,'optimal'};

conditions = {'normal'};

for cond = 1:length(conditions)
   
    params.adapt_params.duration = inf;
    params.adapt_params.delay    = 0.55;
    [vaf,R2,preds,decoders] = train_adapt_duration(traindata,testdata,train_duration,conditions{cond},params);
    
    figure;
    plotLM(train_duration/60,vaf,'o-');
    ylim([-0.1 1]);
    xlim([0 20]);
    legend('Fx','Fy');
    ylabel('VAF');xlabel('Time (min)');
    title([dataset ' - ' conditions{cond} 'del,dur=0.55,inf']);
    
    results = struct(...
        'vaf'       ,vaf,...
        'R2'        ,R2,...
        'preds'     ,preds,...
        'decoders'  ,{decoders});
    assignin('base',['results_' conditions{cond}],results);
end