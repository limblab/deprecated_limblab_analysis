
function params = getMCMCparams(S,idx)

params = [];
for i=1:5
    if isfield(S,['P' num2str(i)])
        tmp = getfield(S,['P' num2str(i)]);
        if idx<0
            params = [params tmp];
        elseif idx==0
            params = [params getfield(S,['P' num2str(i) '_median'])];
        else
            params = [params tmp(idx)];
        end
    end
end