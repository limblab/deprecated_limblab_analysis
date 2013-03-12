function VAFstruct = buildSpike1unitPositionDecoder(bdfIn,singleUnitToUse)

% singleUnitToUse is a list of all the single units to use in turn.

uList=unit_list(bdfIn);
allUnitsIDs=cat(1,bdfIn.units.id);
if size(allUnitsIDs,1)<length(bdfIn.units)
    allUnitsIDs=[allUnitsIDs; ...
        repmat([0 0],length(bdfIn.units)-size(allUnitsIDs,1),1)];
end

if nargin<2
    singleUnitToUse=1:size(uList,1);
end

cells=[];
signal='vel';
folds=10; numlags=10; PolynomialOrder=3; binsize=0.05;
numsides=1; lambda=1; Use_Thresh=0;

warning('off','MATLAB:polyfit:RepeatedPointsOrRescale')
for n=1:length(singleUnitToUse)
    bdf=bdfIn;
    bdf.units(ismember(allUnitsIDs,uList(singleUnitToUse(n),:),'rows')==0)=[];
    
    [vaf_all{n},~,~,~,~,~,~,~,~,~,~,~,~,~,~]=predictions_mwstikpolyMOD(bdf,signal, ...
        cells,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
    close
    fprintf(1,'%d,',n)
    if ~mod(n,30), fprintf(1,'\n'), end
end
fprintf(1,'done.\n')
warning('on','MATLAB:polyfit:RepeatedPointsOrRescale')

VAFstruct.name=bdfIn.meta.filename;
VAFstruct.uList=unit_list(bdfIn);
VAFstruct.vaf=vaf_all;
