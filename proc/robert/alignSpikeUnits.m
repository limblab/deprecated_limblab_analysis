function out_structCurrent=alignSpikeUnits(out_structCurrent,out_structOriginal)

% syntax out_struct=alignSpikeUnits(out_structCurrent,out_structOriginal)
%
% 

uListCurrent=unit_list(out_structCurrent);
uListOriginal=unit_list(out_structOriginal);

diffMaker=setdiff(uListOriginal,uListCurrent,'rows');
if ~isempty(diffMaker)
    for n=1:size(diffMaker,1)
        fprintf(1,'\nadding unit [%d,%d] to %s\n',diffMaker(n,1),diffMaker(n,2),...
            out_structCurrent.meta.filename)
        breakPoint=find(uListCurrent(:,1)<diffMaker(n,1),1,'last');
        out_structCurrent.units=[out_structCurrent.units(1:breakPoint), ...
            struct('id',diffMaker(n,:),'ts',nan(1,10)), ...
            out_structCurrent.units(breakPoint+1:end)];
    end
end

diffMaker=setdiff(uListCurrent,uListOriginal,'rows');
if ~isempty(diffMaker)
    for n=1:size(diffMaker,1)
        fprintf(1,'\nremoving unit [%d,%d] from %s\n',diffMaker(n,1),diffMaker(n,2),...
            out_structCurrent.meta.filename)
        breakPoint=find(uListCurrent(:,1)<diffMaker(n,1),1,'last')+1;
        out_structCurrent.units(breakPoint)=[];        
    end
end