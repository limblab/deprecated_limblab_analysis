
for unit = 2%:length(SortedUnitIndices2)
    unitIndex = SortedUnitIndices2(unit);
    figure
    unit1Trial_2 = cat(2,MeanTrialSpikeRate2(:,unit),MeanTrialForce2(:,2));
    h1 = subplot(1,4,1);
    boxplot(unit1Trial_2(:,1), unit1Trial_2(:,2))
    xlabel('2 force levels')
    ylabel('Firing rate (Hz)')
    
    
    unit1Trial_3 = cat(2,MeanTrialSpikeRate3(:,unit),MeanTrialForce3(:,2));
    h2 = subplot(1,4,2);
    boxplot(unit1Trial_3(:,1), unit1Trial_3(:,2))
    xlabel('3 force levels')
    
    unit1Trial_2again = cat(2,MeanTrialSpikeRate2again(:,unit),MeanTrialForce2again(:,2));
    h3 = subplot(1,4,3);
    boxplot(unit1Trial_2again(:,1), unit1Trial_2again(:,2))
    xlabel('2 force levels')
    
    unit1Trial_3again = cat(2,MeanTrialSpikeRate3again(:,unit),MeanTrialForce3again(:,2));
    h4 = subplot(1,4,4);
    boxplot(unit1Trial_3again(:,1), unit1Trial_3again(:,2))
    xlabel('3 force levels')
    
    linkaxes([h2 h1 h3 h4],'xy')
    maxY = max((cat(1,MeanTrialSpikeRate2(:,unit),MeanTrialSpikeRate3(:,unit),MeanTrialSpikeRate2again(:,unit),MeanTrialSpikeRate3again(:,unit))));
    ylim([-5 maxY+5])
    
    
    suptitle(cat(2, num2str('Jango | March 10 2014 | Unit ID: '), num2str(out_struct_2s.units(1,unitIndex).id)));
    %foldername = 'Y:\user_folders\Stephanie\Data Analysis\ContextDependence\Jango\03-10-14\Jango_031014_FRversusForce\Boxplots\';
    %saveas(gcf, strcat(foldername, 'unit',  num2str(out_struct_2s.units(1,unitIndex).id),'.fig'))
    close
end