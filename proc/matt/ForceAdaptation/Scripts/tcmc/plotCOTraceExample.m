%% center out trace example
useDate = '2013-08-23';
load(fullfile(baseDir,useDate,['CO_FF_BL_' useDate '.mat']));
tt = data.trial_table;
t = data.cont.t;
pos = data.cont.pos;
clear data;

numMoves = 2;
numTargs = 8;
targDist = 8;

figure;
hold all;
% plot target locations
for i=1:numTargs
    xcenter = targDist.*cos((i-1).*pi/4);
    ycenter = targDist.*sin((i-1).*pi/4);

    rectangle('Position',[xcenter-1, ycenter-1, 2, 2],'FaceColor','r');
end
rectangle('Position',[-1,-1,2,2],'FaceColor','g');
axis('square');

% pick first movements to each target
for i=1:numTargs
    useInds = find(tt(:,2)==i-1,numMoves,'first');
    for j = 1:length(useInds)
        trial = tt(useInds(j),:);
        usePos = pos(t>=trial(8) & t<trial(end),:);
        plot(usePos(:,1)-xoffset,usePos(:,2)-yoffset,'b','LineWidth',2);
    end
end
