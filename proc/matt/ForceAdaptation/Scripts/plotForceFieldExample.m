% plots a generic viscous force field profile

fAng = 85.*pi/180;
fMag = 0.15;

numArrows = 20;

% just do a gaussian reach
vec = -3:6/numArrows:3;

figure;
hold all;
axis([-3 3 0 0.5]);
for i = 1:numArrows

    startPos = [vec(i) 0];
    
    val = normpdf(vec(i),0,1);
    
    endPos = [startPos(1)+val*cos(fAng) startPos(2)+val*sin(fAng)];
    
    arrow('Start',startPos,'Stop',endPos,'Width',3);
end

set(gca,'XTick',[],'YTick',[]);