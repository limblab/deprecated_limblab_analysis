function sortInd=sortUnitsOnH(unitList,H,numlags)

% syntax sortInd=sortUnitsOnH(unitList,H,numlags);
%
% unitList is the output of unit_list(bdf)

channelStartInds=(0:size(unitList,1)-1)*numlags+1;
indMat=repmat(channelStartInds,numlags,1)+repmat([0:(numlags-1)]',1,size(unitList,1));
for n=1:size(indMat,2)
    aveH(n)=mean(H(indMat(:,n)));
end
[~,sortInd]=sort(aveH);



