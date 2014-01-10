function [spm,spme] = EMG_cascade_plot_stats(all_stats)

[num_conditions,num_days] = size(all_stats);
num_targets = 8;

%success per minute
spm  = nan(num_targets+1,num_conditions,num_days);
spme = spm;
t2t  = spm;
t2te = spm;
pl   = spm;
ple  = spm;
nre  = spm;
nree = spm;
Ntgt = spm;

for day = 1:num_days
    for cond = 1:num_conditions
        if ~isempty(all_stats{cond,day})
            %1-success rate
            num_mins = size(all_stats{cond,day}.succ_per_min{1},1);
            SR = zeros(num_targets,num_mins);
            for min = 1:num_mins
                for tgt = 1:num_targets
                    SR(tgt,min) = all_stats{cond,day}.succ_per_min{tgt}(min);
                end
            end
            spm(1:end-1,cond,day)  = mean(SR,2);
            spme(1:end-1,cond,day) = std(SR,0,2);
            spm(end,cond,day)      = mean(sum(SR));
            spme(end,cond,day)     = std(sum(SR));
            
            %2-time to target
            for tgt = 1:num_targets
                t2t(tgt,cond,day)  = mean(all_stats{cond,day}.time2target{tgt});
                t2te(tgt,cond,day) = std(all_stats{cond,day}.time2target{tgt});
                Ntgt(tgt,cond,day) = size(all_stats{cond,day}.time2target{tgt},1);
            end
            t2t(end,cond,day) = mean(t2t(1:end-1,cond,day));
            t2te(end,cond,day)= sqrt(mean(t2te(1:end-1,cond,day).^2));
            
            %3-path length
            for tgt = 1:num_targets
                pl(tgt,cond,day)  = mean(all_stats{cond,day}.path_length{tgt});
                ple(tgt,cond,day) = std(all_stats{cond,day}.path_length{tgt});
                Ntgt(tgt) = size(all_stats{cond,day}.path_length{tgt},1);
            end
            pl(end,cond,day) = mean(pl(1:end-1,cond,day));
            ple(end,cond,day)= sqrt(mean(ple(1:end-1,cond,day).^2));
            
            %4-number of re-entries
            for tgt = 1:num_targets
                nre(tgt,cond,day)  = mean(all_stats{cond,day}.num_reentries{tgt});
                nree(tgt,cond,day) = std(all_stats{cond,day}.num_reentries{tgt});
                Ntgt(tgt) = size(all_stats{cond,day}.num_reentries{tgt},1);
            end
            nre(end,cond,day) = mean(nre(1:end-1,cond,day));
            nree(end,cond,day)= sqrt(mean(nree(1:end-1,cond,day).^2));
            
%             Ntgt(end,cond,day) = sum(Ntgt(1:end-1,cond,day));
        end
    end
    
    figure;
    %number of targets
    subplot(5,1,1);
    bar(Ntgt(:,:,day));
    title(sprintf('Performance Metrics\n Day %d',day));
    set(gca,'XTickLabel',{'Tgt1','Tgt2','Tgt3','Tgt4','Tgt5','Tgt6','Tgt7','Tgt8','-',});
    legend('Hand Control','EMG Cascade','Neurons-to-Force','Location','EastOutside');
    ylabel('N Success');
    
    %success rate
    subplot(5,1,2);
    barwitherr(spme(:,:,day),spm(:,:,day));
    set(gca,'XTickLabel',{'Tgt1','Tgt2','Tgt3','Tgt4','Tgt5','Tgt6','Tgt7','Tgt8','Total',});
    legend('Hand Control','EMG Cascade','Neurons-to-Force','Location','EastOutside');
    ylabel('Success per minutes');
    
    %time to target
    subplot(5,1,3);
    barwitherr(t2te(:,:,day),t2t(:,:,day));
    set(gca,'XTickLabel',{'Tgt1','Tgt2','Tgt3','Tgt4','Tgt5','Tgt6','Tgt7','Tgt8','Mean',});
    legend('Hand Control','EMG Cascade','Neurons-to-Force','Location','EastOutside');
    ylabel('time to target (s)');
    
    %path length
    subplot(5,1,4);
    barwitherr(ple(:,:,day),pl(:,:,day));
    set(gca,'XTickLabel',{'Tgt1','Tgt2','Tgt3','Tgt4','Tgt5','Tgt6','Tgt7','Tgt8','Mean',});
    legend('Hand Control','EMG Cascade','Neurons-to-Force','Location','EastOutside');
    ylabel('path length (cm)');
    
    %number of re-entries
    subplot(5,1,5);
    barwitherr(nree(:,:,day),nre(:,:,day));
    set(gca,'XTickLabel',{'Tgt1','Tgt2','Tgt3','Tgt4','Tgt5','Tgt6','Tgt7','Tgt8','Mean',});
    legend('Hand Control','EMG Cascade','Neurons-to-Force','Location','EastOutside');
    ylabel('number of re-rentries)');
        
end

            
            
        

        
    
    