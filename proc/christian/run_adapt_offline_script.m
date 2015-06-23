
train_duration = [2.5 5 7.5 10 12.5 15 17.5 20 25 30 35 40 45 50 55];
conditions = {'optimal','optimal_target','normal'};

for test_file = 6:6
    
    filename  = all_data{test_file,1};
    traindata = all_data{test_file,2};
    testdata  = all_data{test_file,3};
    
    save_path = ['/Users/christianethier/Desktop/TrainDuration_[opt-opt_tgt-norm]' filesep filename '_long' filesep];
    if ~isdir(save_path)
        mkdir(save_path)
    end
    
    for cond = 1:length(conditions)
        
        [vaf,R2,preds,decoders,figh] = train_adapt_duration(traindata,testdata,60*train_duration,conditions{cond});
        
        % save Fpred figures
        for i = 1:size(figh,1)
            if any(figh(i,:))
                savefig(figh(i,1),[save_path filename '_' conditions{cond} '_' strrep(num2str(train_duration(i)),'.',',') 'min_Fx']);
                savefig(figh(i,2),[save_path filename '_' conditions{cond} '_' strrep(num2str(train_duration(i)),'.',',') 'min_Fy']);
                
                print2eps([save_path filename '_' conditions{cond} '_' strrep(num2str(train_duration(i)),'.',',') 'min_Fx'],figh(i,1));
                print2eps([save_path filename '_' conditions{cond} '_' strrep(num2str(train_duration(i)),'.',',') 'min_Fy'],figh(i,2));
                close(figh(i,1));
                close(figh(i,2));
            end
        end

        % plot VAF vs train duration
        fh = figure;
        plotLM(train_duration,vaf,'o-');
        ylim([0 1]);
        xlim([0 max(train_duration)]);
        legend('Fx','Fy');
        ylabel('VAF');xlabel('Time (min)');
        title(strrep([filename ' - ' conditions{cond}],'_','\_'));
        % save vaf figure
        savefig(fh,[save_path filename '_' conditions{cond} '_VAFvsTrainDuration_fig']);
        print2eps([save_path filename '_' conditions{cond} '_VAFvsTrainDuration_fig'],fh);
        
        % plot R2 vs train duration
        fh = figure;
        plotLM(train_duration,R2,'o-');
        ylim([0 1]);
        xlim([0 max(train_duration)]);
        legend('Fx','Fy');
        ylabel('R2');xlabel('Time (min)');
        title(strrep([filename ' - ' conditions{cond}],'_','\_'));       
        % save vaf figure
        savefig(fh,[save_path filename '_' conditions{cond} '_R2vsTrainDuration_fig']);
        print2eps([save_path filename '_' conditions{cond} '_R2vsTrainDuration_fig'],fh);             
        
        results = struct(...
            'vaf'       ,vaf,...
            'R2'        ,R2,...
            'preds'     ,preds,...
            'decoders'  ,{decoders});
        assignin('base',['results_' filename '_' conditions{cond}],results);
        
        % save results
        save([save_path filename '_' conditions{cond} '_TrainDuration_results'],'results');
    end
end
clear vaf R2 preds decoders cond params

% %% post_processing emg_plotting
% 
% act_emgs  = cell(6,1);
% pred_emgs = cell(6,1); 
% 
% for f = 1:6    
%     act_emgs{f} = all_data{f,3}.emgdatabin;
%     
%     if mean(mean(act_emgs{f}))>1
%         num_emgs    = size(all_data{f,3}.emgdatabin,2);
%         for i = 1:num_emgs
%             act_emgs{f}(:,i) = act_emgs{f}(:,i)/prctile(act_emgs{f}(:,i),99);
%         end
%     end
%     spikes       = all_data{f,3}.spikeratedata;
%     decoder      = eval([normal_list{f} '.decoders{end}']);
%     pred_emgs{f} = sigmoid(predMIMOCE3(spikes,decoder.H),'direct');
% end
% 
% %% look at data distribution :/
% for i = 1:6
%     figure;
%     hist(all_data{i,3}.cursorposbin(:,1),50);
%     title(sprintf('%s \nvar(Fx) = %.2f',strrep(all_data{i,1},'_','\_'),var(all_data{i,3}.cursorposbin(:,1))));
%     pretty_fig(gca);
%     xlim([-16 16]);
%     figure;
%     hist(all_data{i,3}.cursorposbin(:,2),50);
%     title(sprintf('%s \nvar(Fy) = %.2f',strrep(all_data{i,1},'_','\_'),var(all_data{i,3}.cursorposbin(:,2))));
%     pretty_fig(gca);
%     xlim([-16 16]);
% end