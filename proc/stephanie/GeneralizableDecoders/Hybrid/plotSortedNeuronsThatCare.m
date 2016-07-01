function plotSortedNeuronsThatCare(SortedNeuronsThatCare_Hybrid, SortedNeuronsThatCare_IsoTrain,SortedNeuronsThatCare_WmTrain,plotTitle,foldername,saveON)

SortedNeuronsThatCare_Hybrid = SortedNeuronsThatCare_Hybrid(1:14,:);
SortedNeuronsThatCare_IsoTrain = SortedNeuronsThatCare_IsoTrain(1:14,:);
SortedNeuronsThatCare_WmTrain = SortedNeuronsThatCare_WmTrain(1:14,:);

figure
LineWidth = 3;
plot(SortedNeuronsThatCare_Hybrid(:,1),SortedNeuronsThatCare_Hybrid(:,2),'rv','LineWidth',LineWidth)
hold on; plot(SortedNeuronsThatCare_IsoTrain(:,1),SortedNeuronsThatCare_IsoTrain(:,2),'k*','LineWidth',LineWidth+3)
hold on; plot(SortedNeuronsThatCare_WmTrain(:,1),SortedNeuronsThatCare_WmTrain(:,2),'go','LineWidth',LineWidth-1)
ylim([.75 3.25])
set(gca,'TickDir','out')
box off
legend('Hybrd','Iso','Move')
xlabel('Channel')
ylabel('NeuronNumber')


membership1 = ismember(SortedNeuronsThatCare_Hybrid,SortedNeuronsThatCare_IsoTrain,'rows');
SameBetweenHybridAndIso = SortedNeuronsThatCare_Hybrid(membership1,:);
membership2 = ismember(SameBetweenHybridAndIso,SortedNeuronsThatCare_WmTrain,'rows');
totalMatches = sum(membership2);

title(strcat(plotTitle,  ':', num2str(totalMatches), ' matches'))

if saveON == 1
saveas(gcf, strcat(foldername, '_NeuronsThatCare_', plotTitle, '.fig'))
saveas(gcf, strcat(foldername, '_NeuronsThatCare_', plotTitle, '.pdf'))
end


end
