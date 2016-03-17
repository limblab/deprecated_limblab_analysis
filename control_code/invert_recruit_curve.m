function ampsOUT = invert_recruit_curve(costim_level,costimComb,recruitFilename)

% Load sigmoid function
load(recruitFilename); % sigParams, mle_cond, muscMVC

% Extract sigmoid parameters for muscles in given costim
params = sigParams(:,costimComb);
amps = zeros(size(params,2),1);
f = costim_level/100*muscMVC(costimComb);
for ii = 1:size(params,2)
   amps(ii) = (-log((1-params(2,ii))/(f(ii)/params(1,ii)-params(2,ii))-1) + params(4,ii))/params(3,ii); 
end

ampsOUT = zeros(16,1);
ampsOUT(costimComb) = amps;