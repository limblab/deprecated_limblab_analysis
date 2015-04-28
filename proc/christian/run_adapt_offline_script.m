
filename = traindata.meta.filename;
train_duration
% conditions = {'optimal','normal','supervised','N2F_target'};

conditions = {'normal'};

for cond = 1:length(conditions)
   
    params.adapt_params.duration = inf;
    params.adapt_params.delay    = 0.5;
    params.adapt_params.LR       = 1e-7;
    [vaf,R2,preds,decoders] = train_adapt_duration(traindata,testdata,train_duration,conditions{cond},params);
    
    figure;
    plotLM(train_duration/60,vaf,'o-');
    ylim([-0.1 1]);
    xlim([0 60]);
    legend('Fx','Fy');
    ylabel('VAF');xlabel('Time (min)');
    title(sprintf([filename ' - ' conditions{cond} '\n- del,dur=0.5,inf']));
    
    results = struct(...
        'vaf'       ,vaf,...
        'R2'        ,R2,...
        'preds'     ,preds,...
        'decoders'  ,{decoders});
    assignin('base',['results_' conditions{cond}],results);
end

clear vaf R2 preds decoders conditions cond params