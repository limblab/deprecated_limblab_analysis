function plotMvtStates(bdf,States)

numStates = size(States,2);

light_blue = [208 255 255]./255;
pink = [255 182 193]./255;
gray = [112 128 144]./255;
colors = {light_blue pink gray};

figure;
plot(bdf.pos(:,1),bdf.pos(:,2:3));
axis tight;
axis manual;
hold on;

for i = 1:numStates
    for j = 1:size(States{i},1)
        x = [ States{i}(j,1) States{i}(j,2)];
        y = [ 200 200 ];
        area(x,y,-200,'FaceColor',colors{i},'LineStyle','none');
    end
end



