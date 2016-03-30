function badChansGuess=plotCutFPall(cutfp,~)

% syntax badChansGuess=plotCutFPall(cutfp);
%
%           INPUTS
%                       cutfp           - struct array created by
%                       badChannels     - if we want to eliminate certain
%                                         channels from the plot
%
%           OUTPUTS
%                       badChansGuess   - an attempt at automatically 
%                                         determining the channels that
%                                         ought to be excluded.  Based on
%                                         a range calculation.

if nargin < 2
    badChannels=[];
end

switch lower(machineName)
    case 'bumblebeeman'
        figure, set(gcf,'Position',[32 59 972 636])
        % another valid figure position is [41 101 1440 801]
        % another valid figure position is [32 59 972 636]
        set(gca,'Position',[0.0271 0.0499 0.9465 0.9026])
    otherwise
        figure, set(gcf,'Position',[1 0 1440 801])
        % second monitor
        % set(gcf,'Position',[-479 879 1920 1007])
        set(gca,'Position',[0.0281 0.0437 0.9562 0.9315])
end

scaleFactor=1000;
hold off

% experimental: do a CAR, using only 32 channels at a time to calculate the 
% common average to which all channels (in the group) should be referenced.
% do within each file?
for n=1:length(cutfp)
    cutfp(n).data(1:32,:)=bsxfun(@minus,cutfp(n).data(1:32,:), ...
        mean(cutfp(n).data(1:32,:),1));
    cutfp(n).data(33:64,:)=bsxfun(@minus,cutfp(n).data(33:64,:), ...
        mean(cutfp(n).data(33:64,:),1));
    cutfp(n).data(65:96,:)=bsxfun(@minus,cutfp(n).data(65:96,:), ...
        mean(cutfp(n).data(65:96,:),1));
end

plotTimes=0;
for n=1:length(cutfp)
    cutfp(n).data(badChannels,:)=[];
	plotTimes=plotTimes(end)+1+cutfp(n).times;
	for k=1:size(cutfp(n).data,1)
		if isfield(cutfp(n),'bestc') && ~isempty(intersect(k,cutfp(n).bestc))
			plot(plotTimes,scaleFactor*k+cutfp(n).data(k,:),'g')
		else
			plot(plotTimes,scaleFactor*k+cutfp(n).data(k,:),'r')
		end
		hold on
	end
end
axis tight
title(regexp(cutfp(1).name,'.*(?=[0-9]{3})','match','once'), ...
    'Interpreter','none')

%% guess at bad channels based on limited data available
allCutFP=cat(2,cutfp.data);
badChansGuess=find(range(allCutFP(1:32,:),2) >= ...
    (median(range(allCutFP(1:32,:),2))+2*iqr(range(allCutFP(1:32,:),2))));
badChansGuess=[badChansGuess; find(range(allCutFP(1:32,:),2) <= ...
    (median(range(allCutFP(1:32,:),2))-2*iqr(range(allCutFP(1:32,:),2))))];

badChansGuess=[badChansGuess; find(range(allCutFP(33:64,:),2) >= ...
    (median(range(allCutFP(33:64,:),2))+2*iqr(range(allCutFP(33:64,:),2))))+32];
badChansGuess=[badChansGuess; find(range(allCutFP(33:64,:),2) <= ...
    (median(range(allCutFP(33:64,:),2))-2*iqr(range(allCutFP(33:64,:),2))))+32];

badChansGuess=[badChansGuess; find(range(allCutFP(65:96,:),2) >= ...
    (median(range(allCutFP(65:96,:),2))+2*iqr(range(allCutFP(65:96,:),2))))+64];
badChansGuess=[badChansGuess; find(range(allCutFP(65:96,:),2) <= ...
    (median(range(allCutFP(65:96,:),2))-2*iqr(range(allCutFP(65:96,:),2))))+64];

badChansGuess=unique(badChansGuess);
rangeForPlot=range(allCutFP,2);
figure, plot(rangeForPlot,'.'), hold on, plot(badChansGuess,rangeForPlot(badChansGuess),'r.')
title('bad channel estimate is in red')
