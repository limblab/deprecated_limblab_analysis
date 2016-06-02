function plotNormEMGs(IOcurves,filepath)

for elec = 1:100
    
    numPW = length(IOcurves.electrode(elec).PW);
    
    if numPW <=1
        continue;
    end
    
    [sPW,sidx] = sortrows(IOcurves.electrode(elec).PW);
    sNEMG = IOcurves.electrode(elec).normalized(sidx,:);
    
    fh = figure;
    semilogx(sPW, sNEMG(:,1:4),'-s');
    ylim([0 1]);
    title(sprintf('Electrode %d',elec));
    legend('FDS','FCR','FPB','FDP','Location','Northwest');
    saveas(fh,[filepath sprintf('elec%d',elec)],'fig');
end
