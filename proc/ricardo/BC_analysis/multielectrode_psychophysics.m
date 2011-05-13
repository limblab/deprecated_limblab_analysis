load('D:\Data\Pedro_4C2\allel')
electrode_list = [];
close all

fit_func = 'a+b/(1+exp(x*c+d))';
f_sigmoid = fittype(fit_func,'independent','x');
color_counter = zeros(1,100);
colors = colormap(jet);
% colors = colors(randperm(64),:);
colors = colors(1:6:end,:);

electrode_miu = cell(1,100);
electrode_current = cell(1,100);

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

                subplot(3,1,1)
                hold on 
                miu = rewards./(rewards+incompletes);
                plot(currents,miu,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
                sigmoid_fit = fit(currents',miu',f_sigmoid);
                h_temp = plot(sigmoid_fit);
                set(h_temp,'Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
                ylim([0 1])
                xlim([0 100])
                title('Not normalized')

                subplot(3,1,2)
                hold on 
                miu = rewards./(rewards+incompletes);
                miu_prime = (miu-min_miu)/(1-min_miu);
                electrode_miu{electrodes_iFile(iElectrode)} = [electrode_miu{electrodes_iFile(iElectrode)} miu_prime];
                electrode_current{electrodes_iFile(iElectrode)} = [electrode_current{electrodes_iFile(iElectrode)} currents];
                plot(currents,miu_prime,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
                sigmoid_fit = fit(currents',miu_prime',f_sigmoid);
                h_temp = plot(sigmoid_fit);
                set(h_temp,'Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
                ylim([0 1])
                xlim([0 100])
                legend off
                title('Normalized')

                subplot(3,1,3)
                plot(currents,miu_prime,'.','Color',colors(color_counter(electrodes_iFile(iElectrode)),:))
                ylim([0 1])
                xlim([0 100])
                hold on 
                title('Combined')
            end
        end
    end
end

electrode_list(electrode_list==0) = [];
for iElectrode = 1:length(electrode_list)    
    if ~isempty(electrode_current{electrode_list(iElectrode)})
        figure(electrode_list(iElectrode))
        subplot(3,1,3)
        hold on
%         plot(electrode_current{electrode_list(iElectrode)}',electrode_miu{electrode_list(iElectrode)}','.')
        sigmoid_fit = fit(electrode_current{electrode_list(iElectrode)}',electrode_miu{electrode_list(iElectrode)}',...
            f_sigmoid);
        h_temp = plot(sigmoid_fit);
    %     set(h_temp,'Color',colors(color_counter(iElectrode),:))
        ylim([0 1])
        xlim([0 100])
        legend off
    end
end

