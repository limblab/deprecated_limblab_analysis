function [nfeat,lambda]=paramSweepPlot_numFeatLambda(VAFstruct,paramStructIn)

% syntax [nfeat,lambda]=paramSweepPlot_numFeatLambda(VAFstruct,paramStructIn);
%
% 

for p=1:size(VAFstruct,1)
    m=1;
    for n=1:numel(paramStructIn.nfeat)
        for k=1:numel(paramStructIn.lambda)
            VAFarray{n,k}=nonzeros(VAFstruct(p,m).vaf_vald);
            % VAFarray{n,k}=mean(nonzeros(VAFstruct(p,m).vaf_vald));
            m=m+1;
        end, clear k
    end, clear n m
    
    VAFarray=cellfun(@mean,VAFarray);
    [val,ind]=max(VAFarray(:));
    [featInd,lambdaInd]=ind2sub(size(VAFarray),ind);
    
    if ~nargout
        figure, imagesc(VAFarray)
        set(gca,'XTickLabel',regexp(sprintf('%d,',paramStructIn.lambda),'[0-9]+(?=,)','match'))
        set(gca,'YTickLabel',regexp(sprintf('%d,',paramStructIn.nfeat),'[0-9]+(?=,)','match'))
        set(gca,'YTick',1:numel(paramStructIn.nfeat))
        set(gca,'TickLength',[0 0])
        clear VAFarray
        caxis([0 1])
        
        text(lambdaInd,featInd,'*','HorizontalAlignment','center', ...
            'VerticalAlignment','middle','FontSize',24,'Tag','maxTag')
        title(sprintf('%s: max %.2f at nfeat=%d/%d (%.0f%%), lambda=%d', ...
            VAFstruct(p,1).name,val, ...
            paramStructIn.nfeat(featInd),max(paramStructIn.nfeat), ...
            100*paramStructIn.nfeat(featInd)/max(paramStructIn.nfeat), ...
            paramStructIn.lambda(lambdaInd)),'Interpreter','none')
    else
        nfeat(p)=paramStructIn.nfeat(featInd);
        lambda(p)=paramStructIn.lambda(lambdaInd);
    end
    clear val ind featInd lambdaInd
end, clear p

%#ok<*AGROW,*SAGROW>