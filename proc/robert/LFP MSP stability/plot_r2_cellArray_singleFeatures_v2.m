function plot_r2_cellArray_singleFeatures_v2(r2Array,bestc,bestf,bandsToUse,featIndFromDecoder,DateMat,numFeatsToSample)

% syntax plot_r2_cellArray_singleFeatures_v2(r2Array,bestc,bestf,bandsToUse,featIndFromDecoder,DateMat,numFeatsToSample)
%
% this function only works with 2D r2Array.  If there is a monkey dimension
% in the input array, squeeze it out before passing it to this function.
%
% DateMat can be generated using something like 
% datenum(regexp(HbankDays,'[0-9]{8}','match','once'),'mmddyyyy')-datenum('09-01-2011');
% if no mask is provided, all dates will be included.  If you want to
% exclude some dates, give DateMat a 2nd column with a mask of 1s for days
% to include and zeros for days to exclude, such as (following after the
% previous example):
% DateMat(:,2)=ones(numel(DateMat),1);
% DateMat(DateMat(:,1)<90,2)=0;
%
% v2 displays the colormap of performance arranged by band, and includes 
% the option to subsample the included features.  numFeatsToSample can be
% a scalar, in which case it tells how many features to sample.  
% numFeatsToSample can also be a vector, where numel(numFeatsToSample)
% tells how many times to re-sample, and each numFeatsToSample(n) tells how
% many samples to take in that iteration of the bootstrap.

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
% prepare, in order to be able to display according to band
[bestfKept,~]=ind2sub([6 96],featToKeep);

% average same days
if nargin < 6
    DateMat=rowBoat(1:size(r2Avg,2)); % default to reporting each file
    DateMat(:,2)=ones(numel(DateMat),1);
end
r2Avg(:,DateMat(:,2)==0)=[];
DateMat(DateMat(:,2)==0,:)=[];
uDateVec=unique(DateMat(:,1),'stable');
r2AvgDays=nan(size(r2Avg,1),length(uDateVec));
for n=1:length(uDateVec)
    r2AvgDays(:,n)=mean(r2Avg(:,DateMat(:,1)==uDateVec(n)),2);
end

% rearrange r2AvgDays so that bands are together
bandsPresent=unique(bestfKept);
r2AvgDaysArranged=[];
for n=1:length(bandsPresent)
    % within band, go from highest r2 at top, down to lowest r2 at bottom
    r2thisBand=r2AvgDays(bestfKept==bandsPresent(n),:);
    featsInBand(n)=size(r2thisBand,1);
    % sort by mean across days (columns), so that the map as a whole 
    % tends to go from more red at top, to more blue at bottom.
    [~,sortInd]=sort(mean(r2thisBand,2),'descend');
    r2AvgDaysArranged=[r2AvgDaysArranged; r2thisBand(sortInd,:)];
end
bandsPossible={'LMP','0-4','7-20','70-115','130-200','200-300'};
figure, imagesc(uDateVec,1:size(r2AvgDaysArranged,1),r2AvgDaysArranged)
set(gca,'FontSize',16,'FontWeight','bold','YTick',cumsum(featsInBand), ...
    'YTickLabel',bandsPossible(bandsPresent))

if nargin < 7
    numFeatsToSample=size(r2AvgDaysArranged,1);
end

for n=1:numel(numFeatsToSample)
    if n>1, close, end
    if nargin < 7
        indsToUse=rowBoat(1:size(r2AvgDaysArranged,1));
    else
        indsToUse=sort(randi(size(r2AvgDaysArranged,1),[1 numFeatsToSample(n)]));
    end
    try
        [~,~,~,~,~,~] = CorrCoeffMap(r2AvgDaysArranged(indsToUse,:),0);
        set(gca,'FontSize',16,'FontWeight','bold')
    catch ME
        if isequal(ME.identifier,'MATLAB:UndefinedFunction')
            % we do need this function to exist for the line plot to make any
            % sense.
            rethrow(ME)
        end
    end
    caxis([0 1])
    SIvalues(:,n)=nanmean(get(get(gca,'Children'),'CData'),2);
end
figure, set(gcf,'Position',[160    93   950   420])
plot(uDateVec,mean(SIvalues,2),'ok','LineWidth',2)
set(gca,'Ylim',[0 1],'FontSize',16,'box','off')         % 'XTick',[min(get(gca,'Xlim')) max(get(gca,'Xlim'))]
set(gcf,'Color',[0 0 0]+1)
set(gca,'FontSize',16,'FontWeight','bold','Position',[0.0516 0.1100 0.8853 0.7995])