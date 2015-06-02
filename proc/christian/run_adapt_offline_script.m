
train_duration = [2.5 5 7.5 10 12.5 15 17.5 20];
conditions = {'optimal','normal','supervised','N2F_target'};

for test_file = 1:6
    
    filename  = all_data{test_file,1};
    traindata = all_data{test_file,2};
    testdata  = all_data{test_file,3};
    
    save_path = ['/Users/christianethier/Dropbox/Adaptation/Results/Train_Duration/' filename '/'];
    if ~isdir(save_path)
        mkdir(save_path)
    end
    
    for cond = 1:length(conditions)
        
        [vaf,R2,preds,decoders,figh] = train_adapt_duration(traindata,testdata,60*train_duration,conditions{cond});
        
        % save Fpred figures
        for i = 1:size(figh,1)
            savefig(figh(i,1),[save_path filename '_' conditions{cond} '_' strrep(num2str(train_duration(i)),'.',',') 'min_Fx']);
            savefig(figh(i,2),[save_path filename '_' conditions{cond} '_' strrep(num2str(train_duration(i)),'.',',') 'min_Fy']);
            
            print2eps([save_path filename '_' conditions{cond} '_' strrep(num2str(train_duration(i)),'.',',') 'min_Fx'],figh(i,1));
            print2eps([save_path filename '_' conditions{cond} '_' strrep(num2str(train_duration(i)),'.',',') 'min_Fy'],figh(i,1));
            close(figh(i,1));
            close(figh(i,2));
        end
        
        fh = figure;
        plotLM(train_duration,vaf,'o-');
        ylim([0 1]);
        xlim([0 max(train_duration)]);
        legend('Fx','Fy');
        ylabel('VAF');xlabel('Time (min)');
        title([strrep(filename,'_','\_') ' - ' conditions{cond}]);
        
        % save vaf figure
        savefig(fh,[save_path filename '_' conditions{cond} '_VAFvsTrainDuration_fig']);
        print2eps([save_path filename '_' conditions{cond} '_VAFvsTrainDuration_fig'],fh);
        
        results = struct(...
            'vaf'       ,vaf,...
            'R2'        ,R2,...
            'preds'     ,preds,...
            'decoders'  ,{decoders});
        assignin('base',['results_' filename '_' conditions{cond}],results);
        
        % save results
        save([save_path filename '_' conditions{cond} '_VAFvsTrainDuration_results'],'results');
    end
end
clear vaf R2 preds decoders cond params