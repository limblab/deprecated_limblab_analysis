function plot_r2_cellArray_singleFeatures(r2Array,bestc,bestf,bandsToUse,featIndFromDecoder,DateVec)

% syntax plot_r2_cellArray_singleFeatures(r2Array,bestc,bestf,bandsToUse,featIndFromDecoder,DateVec)
%
% this function only works with 2D r2Array.  If there is a monkey dimension
% in the input array, squeeze it out before passing it to this function.
%
% dateVec can be generated using something like 
% datenum(regexp(HbankDays,'[0-9]{8}','match','once'),'mmddyyyy')-datenum('09-01-2011');

r2Avg=nan(576,size(r2Array,1));
for n=1:size(r2Array,1)
    featind=sub2ind([6 96],bestf{n},bestc{n});
    r2Avg(featind,n)=mean(cat(2,r2Array{n,:}),2);
end
% r2Avg(sum(isnan(r2Avg),2)==size(r2Avg,2),:)=[];

if nargin > 3
    if isempty(bandsToUse)
        bandsToUse=1:6;
    end
    bandInd=zeros(96,length(bandsToUse));
    for n=1:length(bandsToUse)
        bandInd(:,n)=bandsToUse(n):6:size(r2Avg,1);
    end
else
    bandInd=rowBoat(1:size(r2Avg,1));
end
if nargin > 4
    featToKeep=intersect(sort(bandInd(:)),featIndFromDecoder);
else
    featToKeep=sort(bandInd(:));
end
r2Avg=r2Avg(featToKeep,:);

% average same days
if nargin < 6
    DateVec=1:size(r2Avg,2); % default to reporting each file
end
uDateVec=unique(DateVec,'stable');
r2AvgDays=nan(size(r2Avg,1),length(uDateVec));
for n=1:length(uDateVec)
    r2AvgDays(:,n)=mean(r2Avg(:,DateVec==uDateVec(n)),2);
end

figure, imagesc(uDateVec,1:size(r2AvgDays,1),r2AvgDays)
set(gca,'FontSize',16,'FontWeight','bold')

try
    [~,~,~,~,~,~] = CorrCoeffMap(r2AvgDays,0);
    set(gca,'FontSize',16,'FontWeight','bold')
catch ME
    if isequal(ME.identifier,'MATLAB:UndefinedFunction')
        % we do need this function to exist for the line plot to make any
        % sense.
        rethrow(ME)
    end
end
caxis([0 1])
temp=nanmean(get(get(gca,'Children'),'CData'),2); 
figure, set(gcf,'Position',[160    93   950   420])
plot(uDateVec,temp,'ok','LineWidth',2)
set(gca,'Ylim',[0 1],'FontSize',16,'box','off')         % 'XTick',[min(get(gca,'Xlim')) max(get(gca,'Xlim'))]
set(gcf,'Color',[0 0 0]+1)
set(gca,'FontSize',16,'FontWeight','bold','Position',[0.0516 0.1100 0.8853 0.7995])