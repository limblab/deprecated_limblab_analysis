function [nfeat,lambda]=paramSweepPlot_numFeatLambda(VAFstruct,VAFcolKeep)

% syntax [nfeat,lambda]=paramSweepPlot_numFeatLambda(VAFstruct,VAFcolKeep);
%
% 

if nargin < 2
    VAFcolKeep=1:size(VAFstruct(1).vaf_vald,2);
end
nfeatAll=unique(cat(1,VAFstruct.nfeat));
lambdaAll=unique(cat(1,VAFstruct.lambda));

for p=1:size(VAFstruct,1)
    m=1;
    for n=1:numel(nfeatAll)
        for k=1:numel(lambdaAll)
            VAFarray{n,k}=nonzeros(VAFstruct(p,m).vaf_vald(:,VAFcolKeep));
            % VAFarray{n,k}=mean(nonzeros(VAFstruct(p,m).vaf_vald));
            m=m+1;
        end, clear k
    end, clear n m
    
    VAFarray=cellfun(@mean,VAFarray);
    [val,ind]=max(VAFarray(:));
    [featInd,lambdaInd]=ind2sub(size(VAFarray),ind);
    
    if ~nargout
        figure, imagesc(VAFarray)
        set(gca,'XTickLabel',regexp(sprintf('%d,',lambdaAll),'[0-9]+(?=,)','match'))
        set(gca,'YTickLabel',regexp(sprintf('%d,',nfeatAll),'[0-9]+(?=,)','match'))
        set(gca,'YTick',1:numel(nfeatAll))
        set(gca,'TickLength',[0 0])
        clear VAFarray
        caxis([0 1])
        
        text(lambdaInd,featInd,'*','HorizontalAlignment','center', ...
            'VerticalAlignment','middle','FontSize',24,'Tag','maxTag')
        title(sprintf('%s: max %.2f at nfeat=%d/%d (%.0f%%), lambda=%d', ...
            VAFstruct(p,1).name,val, ...
            nfeatAll(featInd),max(nfeatAll), ...
            100*nfeatAll(featInd)/max(nfeatAll), ...
            lambdaAll(lambdaInd)),'Interpreter','none')
    else
        nfeat(p)=nfeatAll(featInd);
        lambda(p)=lambdaAll(lambdaInd);
    end
    clear val ind featInd lambdaInd
end, clear p

%#ok<*AGROW,*SAGROW>