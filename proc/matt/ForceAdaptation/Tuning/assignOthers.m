function cellClasses = assignOthers(cellClasses,cellPDs)
% compute an index for "other" type cells to assign them to memory cells or
% adapting cells
%   tied to investigateMemoryCells;

for iFile = 1:length(cellClasses)
    pds = cellPDs{iFile};
    c = cellClasses{iFile};
    
    pds_bl = pds{1};
    pds_ad = pds{2};
    pds_wo = pds{3};
    
    % find "other" type cells
    idx = find(c==5);
    
    for i = 1:length(idx)
        % calculate the memory cell index
        
        bl_wo = angleDiff( pds_bl(idx(i),1),pds_wo(idx(i),1),true,true );
        bl_ad = angleDiff( pds_bl(idx(i),1), pds_ad(idx(i),1),true,true );
        ad_wo = angleDiff(pds_ad(idx(i),1),pds_wo(idx(i),1),true,true);
        
        mem_ind = abs(bl_wo) / min( abs(bl_ad) , abs(ad_wo) );
        
        if mem_ind > 1
            if sign(bl_wo)==sign(bl_ad)
                c(idx(i)) = 3;
            else
                c(idx(i)) = 2;
            end
        elseif mem_ind < 1
            c(idx(i)) = 2;
        else
            disp('Hey! This one is exactly one.');
            c(idx(i)) = 3;
        end
    end
    
    cellClasses{iFile} = c;
end

end