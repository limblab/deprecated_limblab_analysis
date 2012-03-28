% neurons = [row, column, inverse depth, type, location, num neurons];
% type:  cutaneous=1,proprio=2,motor=3,not driven=4, quiet=5
% location: 1=hand,2=lower arm,3=upper arm,4=trunk,5=face,6=other
Pedro_folder = 'Z:\lab_folder\Animal-Miscellany\Pedro 4C2\';
Pedro_data = 'Y:\Pedro_4C2\Microdrive\';
[ndata, headertext] = xlsread([Pedro_folder '\Pedro 4C2 Daily Log.xlsx'], 'mapping neurons');
ndata = ndata(:,1:6);
ndata = ndata(1:find(isnan(ndata(:,1)),1,'first')-1,:);
neurons = ndata;

% stuck_electrodes = [1 1; 6 1; 4 2; 4 3; 4 7; 7 7; 3 8];
% broken_electrodes = [7 2; 4 5; 5 9];

stuck_electrodes = [1 1; 1 6; 2 4; 3 4; 7 4; 7 7; 8 3];
broken_electrodes = [2 7; 5 4; 9 5];

penetrations = unique(neurons(:,[1 2]),'rows');

type_colors = jet(4)*.8;
type_colors(end+1,:) = [0.8 0.8 0.8];
location_colors = jet(5)*.8;
location_colors(end+1,:) = [0.8 0.8 0.8];

sulcus = [5.5, 0;
    5.5, 1;
    5.5, 2;
    5.7, 3;
    5.8, 4;
    6.2, 5;
    6.9, 6;
    7.7, 7;
    9, 8];

[electrodesX electrodesY electrodesZ] = meshgrid(1:9,1:7,0);

h1 = figure(1); % Neuron type
clf
set(gcf,'Position',[200,200,800,600])
hold on
for iColor = 1:length(type_colors)
    plot3(-1,-1,-1,'Color',type_colors(iColor,:),'LineWidth',10)
end
legend('Cutaneous','Proprioceptive','Motor','Not driven','Quiet','Location','SouthEastOutside')
plot3(sulcus(:,1),sulcus(:,2),zeros(size(sulcus,1)),'Color',[.7 .7 .7],'LineWidth',3)
hold on
plot3(electrodesX, electrodesY, electrodesZ,'.','Color',[.8 .8 .8])
plot3(stuck_electrodes(:,1),stuck_electrodes(:,2),zeros(length(stuck_electrodes)),'x','Color',[.5 .5 0],'MarkerSize',10)
plot3(broken_electrodes(:,1),broken_electrodes(:,2),zeros(length(broken_electrodes)),'xr','MarkerSize',10)
for iNeuron = 1:size(neurons,1)
    plot3(neurons(iNeuron,1),neurons(iNeuron,2),10-neurons(iNeuron,3),...
        '.','Color',type_colors(neurons(iNeuron,4),:),'MarkerSize',20)
end
for iPenetration = 1:size(penetrations,1)
    plot3([penetrations(iPenetration,1) penetrations(iPenetration,1)],...
        [penetrations(iPenetration,2) penetrations(iPenetration,2)],...
        [0 10],'-','Color',[.8 .8 .8])
end    
text(0,4,5,'Anterior')
text(10,4,5,'Posterior')
text(5,0,5,'Lateral (right)')
text(5,8,5,'Medial (left)')
xlim([0 10])
ylim([0 8])
set(gca,'XTick',[1:9])
set(gca,'XTickLabel',{'A','B','C','D','E','F','G','H','I'})
set(gca,'YTick',[1:7])
set(gca,'ZDir','reverse','XDir','reverse')
set(gca,'DataAspectRatio',[1 1 3/4])
ylabel('Row')
xlabel('Column')
zlabel('Approximate depth (mm)')
title('Neurons by receptive field type')
saveas(h1,[Pedro_data 'Microdrive RF types as of ' datestr(now,29)],'png')
saveas(h1,[Pedro_data 'Microdrive RF types as of ' datestr(now,29)],'fig')

h2 = figure(2) % Location
clf
set(gcf,'Position',[200,200,800,600])
hold on
for iColor = 1:length(location_colors)
    plot3(-1,-1,-1,'Color',location_colors(iColor,:),'LineWidth',10)
end
legend('Hand','Lower arm','Upper arm','Trunk','Face','Other','Location','SouthEastOutside')
plot3(sulcus(:,1),sulcus(:,2),zeros(size(sulcus,1)),'Color',[.7 .7 .7],'LineWidth',3)
hold on
plot3(electrodesX, electrodesY, electrodesZ,'.','Color',[.8 .8 .8])
plot3(electrodesX, electrodesY, electrodesZ,'.','Color',[.8 .8 .8])
plot3(stuck_electrodes(:,1),stuck_electrodes(:,2),zeros(length(stuck_electrodes)),'x','Color',[.5 .5 0],'MarkerSize',10)

for iNeuron = 1:size(neurons,1)
    plot3(neurons(iNeuron,1),neurons(iNeuron,2),10-neurons(iNeuron,3),...
        '.','Color',location_colors(neurons(iNeuron,5),:),'MarkerSize',20)
end
for iPenetration = 1:size(penetrations,1)
    plot3([penetrations(iPenetration,1) penetrations(iPenetration,1)],...
        [penetrations(iPenetration,2) penetrations(iPenetration,2)],...
        [0 10],'-','Color',[.8 .8 .8])
end
text(0,4,5,'Anterior')
text(10,4,5,'Posterior')
text(5,0,5,'Lateral (right)')
text(5,8,5,'Medial (left)')
xlim([0 10])
ylim([0 8])
set(gca,'XTick',[1:9])
set(gca,'XTickLabel',{'A','B','C','D','E','F','G','H','I'})
set(gca,'YTick',[1:7])
set(gca,'ZDir','reverse','XDir','reverse')
set(gca,'DataAspectRatio',[1 1 3/4])
ylabel('Row')
xlabel('Column')
zlabel('Approximate depth (mm)')
title('Neurons by receptive field location')
saveas(h2,[Pedro_data 'Microdrive RF locations as of ' datestr(now,29)],'png')
saveas(h2,[Pedro_data 'Microdrive RF locations as of ' datestr(now,29)],'fig')