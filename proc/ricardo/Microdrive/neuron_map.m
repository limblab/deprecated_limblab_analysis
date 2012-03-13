% neurons = [row, column, inverse depth, type, location, num neurons];
% type:  cutaneous=1,proprio=2,motor=3,not driven=4, quiet=5
% location: 1=hand,2=lower arm,3=upper arm,4=trunk,5=face,6=other

[ndata, headertext] = xlsread('Z:\lab_folder\Animal-Miscellany\Pedro 4C2\Pedro 4C2 Daily Log.xlsx', 'mapping neurons');
ndata = ndata(:,1:6);
ndata = ndata(1:find(isnan(ndata(:,1)),1,'first')-1,:);
neurons = ndata;
% neurons = [7, 8, 8, 1, 5, 1;
%     7, 8, 7, 1, 3, 1;
%     7, 8, 5.5, 1, 3, 10;
%     7, 8, 5, 4, 3, 1;
%     7, 8, 4.5, 4, 3, 2;
%     7, 8, 2, 2, 3, 1;
%     3, 6, 6, 4, 6, 1;
%     3, 6, 5, 2, 1, 1;
%     3, 6, 4.5, 4, 3, 1;
%     3, 6, 4, 4, 3, 1;
%     1, 6, 3, 2, 3, 1;
%     1, 7, 5.5, 2, 3, 1;
%     1, 7, 5, 2, 3, 3;
%     2, 7, 4.5, 2, 2, 1;
%     2, 7, 3.5, 4, 6, 1;
%     2, 7, 3, 5, 6, 0;
%     4, 6, 5.5, 5, 6, 0;
%     4, 6, 5, 5, 6, 0;
%     4, 6, 4.5, 5, 6, 0;
%     4, 6, 4, 5, 6, 0;
%     4, 6, 3.5, 5, 6, 0;
%     5, 8, 6, 2, 3, 1];

penetrations = unique(neurons(:,[1 2]),'rows');

type_colors = jet(4)*.8;
type_colors(end+1,:) = 0;
location_colors = jet(5)*.8;
location_colors(end+1,:) = 0;

sulcus = [0, 5.5;
    1, 5.5;
    2, 5.5;
    3, 5.7;
    4, 5.8;
    5, 6.2;
    6, 6.9;
    7, 7.7;
    8, 9];

[electrodesX electrodesY electrodesZ] = meshgrid(1:7,1:9,0);

figure(1) % Neuron type
clf
hold on
for iColor = 1:length(type_colors)
    plot3(-1,-1,-1,'Color',type_colors(iColor,:),'LineWidth',10)
end
legend('Cutaneous','Proprioceptive','Motor','Not driven','Quiet')
plot3(sulcus(:,1),sulcus(:,2),zeros(size(sulcus,1)),'Color',[.7 .7 .7],'LineWidth',3)
hold on
plot3(electrodesX, electrodesY, electrodesZ,'.','Color',[.8 .8 .8])
for iNeuron = 1:size(neurons,1)
    plot3(neurons(iNeuron,1),neurons(iNeuron,2),10-neurons(iNeuron,3),...
        '.','Color',type_colors(neurons(iNeuron,4),:),'MarkerSize',20)
end
for iPenetration = 1:size(penetrations,1)
    plot3([penetrations(iPenetration,1) penetrations(iPenetration,1)],...
        [penetrations(iPenetration,2) penetrations(iPenetration,2)],...
        [0 10],'-','Color',[.8 .8 .8])
end    
text(4,0,5,'Anterior')
text(4,10,5,'Posterior')
text(0,5,5,'Lateral (right)')
text(8,5,5,'Medial (left)')
xlim([0 8])
ylim([0 10])
set(gca,'YTick',[1:9])
set(gca,'YTickLabel',{'A','B','C','D','E','F','G','H','I'})
set(gca,'XTick',[1:7])
set(gca,'ZDir','reverse')
set(gca,'DataAspectRatio',[1 1 3/4])
xlabel('Row')
ylabel('Column')
zlabel('Approximate depth (mm)')
title('Neurons by receptive field type')

figure(2) % Location
clf
hold on
for iColor = 1:length(location_colors)
    plot3(-1,-1,-1,'Color',location_colors(iColor,:),'LineWidth',10)
end
legend('Hand','Lower arm','Upper arm','Trunk','Face','Other')
plot3(sulcus(:,1),sulcus(:,2),zeros(size(sulcus,1)),'Color',[.7 .7 .7],'LineWidth',3)
hold on
plot3(electrodesX, electrodesY, electrodesZ,'.','Color',[.8 .8 .8])
for iNeuron = 1:size(neurons,1)
    plot3(neurons(iNeuron,1),neurons(iNeuron,2),10-neurons(iNeuron,3),...
        '.','Color',location_colors(neurons(iNeuron,5),:),'MarkerSize',20)
end
for iPenetration = 1:size(penetrations,1)
    plot3([penetrations(iPenetration,1) penetrations(iPenetration,1)],...
        [penetrations(iPenetration,2) penetrations(iPenetration,2)],...
        [0 10],'-','Color',[.8 .8 .8])
end
text(4,0,5,'Anterior')
text(4,10,5,'Posterior')
text(0,5,5,'Lateral (right)')
text(8,5,5,'Medial (left)')
xlim([0 8])
ylim([0 10])
set(gca,'YTick',[1:9])
set(gca,'YTickLabel',{'A','B','C','D','E','F','G','H','I'})
set(gca,'XTick',[1:7])
set(gca,'ZDir','reverse')
set(gca,'DataAspectRatio',[1 1 3/4])
xlabel('Row')
ylabel('Column')
zlabel('Approximate depth (mm)')
title('Neurons by receptive field location')
