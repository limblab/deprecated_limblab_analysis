function new_var = blocked2_cont(oldvar, frames)

% 
% if frames(1) ~= 1
%     frames = [1; frames];
% end

NCOL = size(oldvar,2);
new_var = NaN*ones(max(frames),NCOL);
new_var(frames,1:NCOL) = oldvar;
