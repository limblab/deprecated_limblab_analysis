function p = chi2test(O)
% CHI2TEST - Chi-squared test for independence
%   P = CHI2TEST( O )  returns the p value for the Pearson's Chi-squared
%   test for independence of the observations in O.  Columns represent
%   observations, rows represent categories.

E = (sum(O,1)' * sum(O,2)' / sum(sum(O)))';
chi2 = sum(sum((O-E).^2 ./ E ));
dof = (size(O,1) - 1) + (size(O,2) - 1);

p = 1 - chi2cdf(chi2, dof);

