function makeCurvaturePlots(data,saveFilePath)

paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
clear params;

t = data.cont.t;
blockTimes = t(data.movements.curvature_block_times);
mC = data.movements.curvature_means;
sC = data.movements.curvature_stds;

if size(blockTimes,1) ~= size(mC,1)
    blockTimes = blockTimes';
end

fh = figure;

set(0, 'CurrentFigure', fh);
clf reset;

hold all;
h = area(blockTimes',[mC'-sC' 2*sC']);
set(h(1),'FaceColor',[1 1 1]);
set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
plot(blockTimes,mC,'b','LineWidth',2);

ylabel('Time','FontSize',16);
xlabel('Curvature Magnitude','FontSize',fontSize);
axis('tight');


if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath, [data.meta.epoch '_adaptation_curvature.png']);
    saveas(fh,fn,'png');
else
    pause;
end