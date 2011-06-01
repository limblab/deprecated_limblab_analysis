load('D:\Data\Pedro_4C2\allel')
electrode_list = [];
close all

fit_func = 'a+b/(1+exp(x*c+d))';
f_sigmoid = fittype(fit_func,'independent','x');
f_opts = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1 -1 1 -20]);
color_counter = zeros(1,100);
colors = colormap(jet);
% colors = colors(randperm(64),:);
colors = colors(1:6:end,:);

electrode_miu = cell(1,100);
electrode_current = cell(1,100);
legend_text = cell(1,100);

for iFile=1:length(allel)
    electrodes_iFile = allel(iFile).electrodes;
    electrode_list = unique([electrode_list electrodes_iFile]);
    min_miu = 1;
    for iElectrode = 1:length(electrodes_iFile)
        rewards = cell2mat(allel(iFile).rewards(iElectrode));
        incompletes = cell2mat(allel(iFile).incompletes(iElectrode));
        min_miu = min([min_miu min(rewards./(rewards+incompletes))]);
    end
    for iElectrode = 1:length(electrodes_iFile)
        if electrodes_iFile(iElectrode) == 43
            allel(iFile).filename
        end
        if electrodes_iFile(iElectrode) ~=0
            color_counter(electrodes_iFile(iElectrode)) = color_counter(electrodes_iFile(iElectrode))+1;
            currents = cell2mat(allel(iFile).currents(iElectrode));
            rewards = cell2mat(allel(iFile).rewards(iElectrode));
            incompletes = cell2mat(allel(iFile).incompletes(iElectrode));
            if length(currents) > 1
    %             figure
                if electrodes_iFile(iElectrode)==0
                    figure(100)
                else
                    figure(electrodes_iFile(iElectrode))
                end
                if electrodes_iFile(iElectrode) == 90
                    iFile
                end
%                 subplot(3,1,1)
%                 hold on 
%                 miu = rewards./(rewards+incompletes);
%                 plot(currents,miu,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
%                 sigmoid_fit = fit(currents',miu',f_sigmoid,f_opts);
%                 h_temp = plot(sigmoid_fit);
%                 set(h_temp,'Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
%                 ylim([0 1])
%                 xlim([0 100])
%                 title('Not normalized')
%                 legend_text{electrodes_iFile(iElectrode)}(end+1) = allel(iFile).filename;
                subplot(2,1,1)
                hold on 
                miu = rewards./(rewards+incompletes);
                miu_prime = (miu-min_miu)/(1-min_miu);
                electrode_miu{electrodes_iFile(iElectrode)} = [electrode_miu{electrodes_iFile(iElectrode)} miu_prime];
                electrode_current{electrodes_iFile(iElectrode)} = [electrode_current{electrodes_iFile(iElectrode)} currents];
                plot(currents,miu_prime,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
%                 legend(legend_text{electrodes_iFile(iElectrode)})
%                 sigmoid_fit = fit(currents',miu_prime',f_sigmoid,f_opts);
%                 h_temp = plot(sigmoid_fit);
%                 set(h_temp,'Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
                ylim([0 1])
                xlim([0 100])
                legend off
                title('Normalized')

                subplot(2,1,2)
                plot(currents,miu_prime,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
                ylim([0 1])
                xlim([0 100])
                hold on 
                title('Combined')
            end
        end
    end
    
end

color_counter = zeros(1,100);
for iFile=1:length(allel)
    electrodes_iFile = allel(iFile).electrodes;
    electrode_list = unique([electrode_list electrodes_iFile]);
    min_miu = 1;
    for iElectrode = 1:length(electrodes_iFile)
        rewards = cell2mat(allel(iFile).rewards(iElectrode));
        incompletes = cell2mat(allel(iFile).incompletes(iElectrode));
        min_miu = min([min_miu min(rewards./(rewards+incompletes))]);
    end
    
    for iElectrode = 1:length(electrodes_iFile)
        if electrodes_iFile(iElectrode) == 43
            allel(iFile).filename
        end
        if electrodes_iFile(iElectrode) ~=0
            color_counter(electrodes_iFile(iElectrode)) = color_counter(electrodes_iFile(iElectrode))+1;
            currents = cell2mat(allel(iFile).currents(iElectrode));
            rewards = cell2mat(allel(iFile).rewards(iElectrode));
            incompletes = cell2mat(allel(iFile).incompletes(iElectrode));
            if length(currents) > 1
    %             figure
                if electrodes_iFile(iElectrode)==0
                    figure(100)
                else
                    figure(electrodes_iFile(iElectrode))
                end
                if electrodes_iFile(iElectrode) == 90
                    iFile
                end
%                 subplot(3,1,1)
%                 hold on 
%                 miu = rewards./(rewards+incompletes);
%                 plot(currents,miu,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
%                 sigmoid_fit = fit(currents',miu',f_sigmoid,f_opts);
%                 h_temp = plot(sigmoid_fit);
%                 set(h_temp,'Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
%                 ylim([0 1])
%                 xlim([0 100])
%                 title('Not normalized')
                legend_text{electrodes_iFile(iElectrode)}(end+1) = strrep(allel(iFile).filename,'_','__');
                subplot(2,1,1)
                hold on 
                miu = rewards./(rewards+incompletes);
                miu_prime = (miu-min_miu)/(1-min_miu);
                electrode_miu{electrodes_iFile(iElectrode)} = [electrode_miu{electrodes_iFile(iElectrode)} miu_prime];
                electrode_current{electrodes_iFile(iElectrode)} = [electrode_current{electrodes_iFile(iElectrode)} currents];
%                 plot(currents,miu_prime,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
               
                sigmoid_fit = fit(currents',miu_prime',f_sigmoid,f_opts);
                h_temp = plot(sigmoid_fit);
                set(h_temp,'Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
                legend(legend_text{electrodes_iFile(iElectrode)})
                ylim([0 1])
                xlim([0 100])
                ylabel('R/(R+I)')
                xlabel('')
                title('Session by sesion fits')

%                 subplot(2,1,2)
%                 plot(currents,miu_prime,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
%                 ylim([0 1])
%                 xlim([0 100])
%                 hold on 
%                 title('Combined')
            end
        end
    end
end
%%
electrode_list(electrode_list==0) = [];
for iElectrode = 1:length(electrode_list)    
    if ~isempty(electrode_current{electrode_list(iElectrode)})
        figure(electrode_list(iElectrode))
        subplot(2,1,2)
        hold on
%         plot(electrode_current{electrode_list(iElectrode)}',electrode_miu{electrode_list(iElectrode)}','.')
        [sigmoid_fit gof] = fit(electrode_current{electrode_list(iElectrode)}',electrode_miu{electrode_list(iElectrode)}',...
            f_sigmoid,f_opts);
        h_temp = plot(sigmoid_fit);
    %     set(h_temp,'Color',colors(color_counter(iElectrode),:))
        ylim([0 1])
        xlim([0 100])
        xlabel('Current (uA)')
        ylabel('R/(R+I)')
        legend off
        temp_c = sigmoid_fit.c;
        fit_func2 = ['a+b/(1+exp(x*' num2str(temp_c) '+d))'];
        f_sigmoid2 = fittype(fit_func2,'independent','x');
        f_opts2 = fitoptions('Method','NonlinearLeastSquares','StartPoint',[1 -1 -20],'Lower',[0 -inf -inf]);
        [sigmoid_fit2 gof2] = fit(electrode_current{electrode_list(iElectrode)}',electrode_miu{electrode_list(iElectrode)}',...
                    f_sigmoid2,f_opts2);
        temp = confint(sigmoid_fit2,.95);
        temp = -temp(:,3)/temp_c;
%         plot(temp,
%         text(60,0.1,num2str(temp,4))
        if electrode_list(iElectrode) == 23

        end
    end

end
