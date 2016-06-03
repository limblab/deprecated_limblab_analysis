function [H,P,bestc,bestf]=reduceHcell(H,vaf,P,bestc,bestf)

% syntax [H,P,bestc,bestf]=reduceHcell(H,vaf,P,bestc,bestf);
%
% TODO: account for multi-column H


if iscell(H)
    [val,ind]=max(vaf);
    Hchoice = questdlg(sprintf('H is a cell.  Pick H{%d} (vaf=%.3f)?\n',ind,val), ...
        'H not a double array','Yes','No','Yes');
    % Handle response
    switch Hchoice
        case 'Yes'
            fprintf(1,'evaluating H=H{%d}; and P=P{%d};\n',ind,ind)
            H=H{ind}; P=P{ind};
            if iscell(bestc)
                bestc=bestc{ind};
            end
            if iscell(bestf)
                bestf=bestf{ind};
            end
        case 'No'
            fprintf(1,'leaving H and P alone.  Be sure to modify them yourself.\n')
            return
    end
end % if H was not a cell, the inputs should just pass to the outputs
