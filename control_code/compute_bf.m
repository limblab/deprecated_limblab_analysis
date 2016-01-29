function bf=compute_bf(S1,S2,lim)
% Given two sets of sampling results, compute an approximation of the
% Bayes Factor.  It is assumes the two sets of samples are indeed
% comparable--for example, that they results from sampling two different
% models on the same data.

% Reference: Kass and Raftery, "Bayes Factors"

if nargin<3,
    lp1=S1.log_llhd(:);
    lp2=S2.log_llhd(:);
else
    lp1=S1.log_llhd(1:lim);
    lp2=S2.log_llhd(1:lim);
end

mx=max([lp1; lp2]);
lp1=lp1-mx;
lp2=lp2-mx;

p1=exp(lp1);
p2=exp(lp2);

bf = harmmean(p1) / harmmean(p2);
