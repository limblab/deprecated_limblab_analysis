hold on;
% numStates = size(data.states,2);
% bottom = [-0.1 0.9 1.1 1.3 1.5];
% top    = [ 1.6 1.0 1.2 1.4 1.6];
bottom = -200;
top = 200;
g0 = [200 200 200];
g1 = [120 120 120];
g2 = [90 90 90];
g3 = [60 60 60];
g4 = [30 30 30];
colors = {g0 g1 g2 g3 g4};

endx = 0;
state= 1;

while endx<length(data.timeframe)
    startx = endx + find(data.states(endx+1:end,state),1,'first');
    if isempty(startx)
        break;
    end
    endx   = startx + find(data.states(startx:end,state)==0,1,'first')-2;
    if isempty(endx)
        endx = length(data.timeframe);
    end
    x = [ data.timeframe(startx) data.timeframe(endx)];
    y = [ top(state) top(state)];
    area(x,y,bottom(state),'FaceColor',colors{state}/255,'LineStyle','none');
end