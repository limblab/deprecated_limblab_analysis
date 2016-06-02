function table = glmout2table(glm_output)

chan = [glm_output.chan]';
unit = [glm_output.unit]';

pref_dirs = zeros(1,length(chan));
dm = zeros(1,length(chan));
for i = 1:length(glm_output)
    if isfield(glm_output,'glmdm')
        dm(i) = glm_output(i).glmdm;
    else
        dm(i) = 1;
    end
    pref_dirs(i) = glm_output(i).glmpd;
end

modulation = min(dm/(1*max(dm)),1)';
pref_dirs(pref_dirs<0) = pref_dirs(pref_dirs<0)+2*pi;
pref_dirs = pref_dirs';

table = [chan unit pref_dirs modulation];