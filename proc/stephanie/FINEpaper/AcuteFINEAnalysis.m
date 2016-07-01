%AcuteFINEAnalysis
% This scripts plots acute results for the median nerve

% Muscle list: pronator, FCR, FDS, FDP, Thenar

% Data directory: X:\limblab\User_folders\Stephanie\Data Analysis\AcuteFINEdata


cd('X:\limblab\User_folders\Stephanie\Data Analysis\AcuteFINEdata');
files = dir('X:\limblab\User_folders\Stephanie\Data Analysis\AcuteFINEdata');
fileIndex = find(~[files.isdir]);

for ind = 1:6
    
    % Load the appropriate file
    fileName = files(fileIndex(ind)).name;
    load(fileName);
    
    allSelVal = [procNew.selVal];   
    MuscleNames = [procNew(:,1).muscleNames];
    
    % Get the muscles that were selective
    for a=1:length(procNew(1,:))
        allSelOrder(a,:)=[procNew(:,a).selOrder];
    end
    SelectiveMuscleInd = unique(allSelOrder(:,1));
    NaNind = find(isnan(SelectiveMuscleInd));
    SelectiveMuscleInd(NaNind)=[];
    SelectiveMuscleNames = MuscleNames(SelectiveMuscleInd);
    
    for b=1:length(SelectiveMuscleInd)
        MuscleIndices = find(allSelOrder(:,1)==SelectiveMuscleInd(b));
        MuscleSelectivityValue(b)=(max(allSelVal(MuscleIndices)));
        MuscleIndices = [];
    end
    
    % Initialize polar plot
    %subplot(2,3,ind); 
    theta=0; rho = 1;
    figure
    polar(theta,rho,'.w'); hold on

    
    for c = 1:length(SelectiveMuscleNames) % 30 90 150 210 270 330 0
        switch char(SelectiveMuscleNames(c))
            case 'FCR'
                theta = degtorad(30);
            case 'Pronator'
                theta = degtorad(90);
            case 'Thenar'
                theta = degtorad(150);
            case 'FDP'
                theta = degtorad(210);
            case 'FDS'
                theta = degtorad(270);
            case 'PL'
                theta = degtorad(330);
        end
        allTheta(c) = theta;
    end
    
    % Make the polar plot
    vectorLength = [zeros(1,length(MuscleSelectivityValue)); MuscleSelectivityValue];
    angle = repmat(allTheta,2,1);
    h=polar(angle,vectorLength);
    title([fileName])
    
    % Label polar plot
    polartext = (findall(gcf,'type','text'));
delete(polartext(1:14))
xlims = get(gca,'xlim');
radius = xlims(2)+xlims(2)/8;
text(radius/sqrt(2)+.1,degtorad(30),'FCR');text(-.2,1.1,'Pronator');text(-1.2,.5,'Thenar');
text(-1.05,-.5,'FDP');text(-.1,-1.1,'FDS');text(.9,-.5,'PL');

    
    switch ind
        case 1
            set(h,'color','k','linewidth',2)
        case 2
            set(h,'color','k','linewidth',2)
        case 3
            set(h,'color','k','linewidth',2)
        case 4
            set(h,'color','k','linewidth',2)
        case 5
            set(h,'color','k','linewidth',2)
        case 6
            set(h,'color','k','linewidth',2)
    end
    
    clearvars -except files fileIndex
end


