function [H, pValue, KSstatistic] = kstest2_mat(x1, x2, alpha, tail)
%KSTEST2 Two-sample Kolmogorov-Smirnov goodness-of-fit hypothesis test.
%   H = KSTEST2(X1,X2,ALPHA,TYPE) performs a Kolmogorov-Smirnov (K-S) test 
%   to determine if independent random samples, X1 and X2, are drawn from 
%   the same underlying continuous population. In this function x1 and x2
%   are column matrices, and the kstest2_mat function will perform
%   comparisons between matched columns of x1 and x2 (x1(:,1) will be
%   compared to x2(:,1), (x1(:,2) will be compared to x2(:,2) and so on.
%   ALPHA and TYPE are optional scalar inputs: ALPHA is the desired 
%   significance level (default = 0.05); TYPE indicates the type of test 
%   (default = 'unequal'). H indicates theresult of the hypothesis test: 
%   H = 0 => Do not reject the null hypothesis at significance level ALPHA. 
%   H = 1 => Reject the null hypothesis at significance level ALPHA.
% 
%   Let S1(x) and S2(x) be the empirical distribution functions from the
%   sample vectors X1 and X2, respectively, and F1(x) and F2(x) be the
%   corresponding true (but unknown) population CDFs. The two-sample K-S
%   test tests the null hypothesis that F1(x) = F2(x) for all x, against the
%   alternative specified by TYPE:
%       'unequal' -- "F1(x) not equal to F2(x)" (two-sided test)
%       'larger'  -- "F1(x) > F2(x)" (one-sided test)
%       'smaller' -- "F1(x) < F2(x)" (one-sided test)
%
%   For TYPE = 'unequal', 'larger', and 'smaller', the test statistics are
%   max|S1(x) - S2(x)|, max[S1(x) - S2(x)], and max[S2(x) - S1(x)],
%   respectively.
%
%   The decision to reject the null hypothesis occurs when the significance 
%   level, ALPHA, equals or exceeds the P-value.
%
%   X1 and X2 are vectors of lengths N1 and N2, respectively, and represent
%   random samples from some underlying distribution(s). Missing
%   observations, indicated by NaNs (Not-a-Number), are ignored.
%
%   [H,P] = KSTEST2(...) also returns the asymptotic P-value P.
%
%   [H,P,KSSTAT] = KSTEST2(...) also returns the K-S test statistic KSSTAT
%   defined above for the test type indicated by TYPE.
%
%   The asymptotic P-value becomes very accurate for large sample sizes, and
%   is believed to be reasonably accurate for sample sizes N1 and N2 such 
%   that (N1*N2)/(N1 + N2) >= 4.
%
%   See also KSTEST, LILLIETEST, CDFPLOT.
%

% Copyright 1993-2011 The MathWorks, Inc.
% $Revision: 1.1.8.3 $   $ Date: 1998/01/30 13:45:34 $

% References:
%   Massey, F.J., (1951) "The Kolmogorov-Smirnov Test for Goodness of Fit",
%         Journal of the American Statistical Association, 46(253):68-78.
%   Miller, L.H., (1956) "Table of Percentage Points of Kolmogorov Statistics",
%         Journal of the American Statistical Association, 51(273):111-121.
%   Stephens, M.A., (1970) "Use of the Kolmogorov-Smirnov, Cramer-Von Mises and
%         Related Statistics Without Extensive Tables", Journal of the Royal
%         Statistical Society. Series B, 32(1):115-122.
%   Conover, W.J., (1980) Practical Nonparametric Statistics, Wiley.
%   Press, W.H., et. al., (1992) Numerical Recipes in C, Cambridge Univ. Press.

 
if nargin < 2
    error('kstest2_stat:TooFewInputs','There must be at least 2 inputs to ktest2_mat');
end

[r,c]=size(x1);
[r2,c2]=size(x2);
if r~=r2 | c~=c2
    error('ktest2_mat:MatricesDifferentSizes','The two inputs to ktest2_mat must be column matrices of the same dimensions')
end

mask1=~isnan(x1);
mask2=~isnan(x2);
if min(sum(mask1))<1 | min(sum(mask2))<1
    error('ktest2_mat:NotEnoughData','some columns of the input do not have enough data to make any comparison')
end
%
% Ensure the significance level, ALPHA, is a scalar 
% between 0 and 1 and set default if necessary.
%
if (nargin >= 3) && ~isempty(alpha)
   if ~isscalar(alpha) || (alpha <= 0 || alpha >= 1)
      error('kstest2_mat:BadAlpha','alpha must be a scalar between 0 and 1'); 
   end
else
   alpha  =  0.05;
end
%
% Ensure the type-of-test indicator, TYPE, is a scalar integer from 
% the allowable set, and set default if necessary.
%

if (nargin >= 4) && ~isempty(tail)
   if ischar(tail)
      try
         [~,tail] = internal.stats.getParamVal(tail, ...
             {'smaller','unequal','larger'},'Type');
      catch
         error(message('stats:kstest2:BadTail'));
      end
      tail = tail - 2;
   elseif ~isscalar(tail) || ~((tail==-1) || (tail==0) || (tail==1))
      error(message('stats:kstest2:BadTail'));
   end
else
   tail  =  0;
end
% Calculate F1(x) and F2(x), the empirical (i.e., sample) CDFs.
%
bin_high=max(max([x1;x2]));
bin_low=min(min([x1;x2]));
delta=(bin_high-bin_low)/100;
binEdges    =  [-inf ; [bin_low-delta:delta:bin_high+delta]' ; inf];

binCounts1  =  histc (x1 , binEdges, 1);
clear x1
sumCounts1  =  cumsum(binCounts1)./repmat(sum(binCounts1),length(binEdges),1);


binCounts2  =  histc (x2 , binEdges, 1);
clear x2
sumCounts2  =  cumsum(binCounts2)./repmat(sum(binCounts2),length(binEdges),1);

%sampleCDF1  =  sumCounts1(1:end-1,:);
%sampleCDF2  =  sumCounts2(1:end-1,:);

%
% Compute the test statistic of interest.
%

switch tail
   case  0      %  2-sided test: T = max|F1(x) - F2(x)|.
%      deltaCDF  =  abs(sampleCDF1 - sampleCDF2);
        deltaCDF=   abs(sumCounts1(1:end-1) -   sumCounts2(1:end-1));
   case -1      %  1-sided test: T = max[F2(x) - F1(x)].
%       deltaCDF  =  sampleCDF2 - sampleCDF1;
        deltaCDF=   abs(sumCounts2(1:end-1) -   sumCounts1(1:end-1));
   case  1      %  1-sided test: T = max[F1(x) - F2(x)].
%      deltaCDF  =  sampleCDF1 - sampleCDF2;
        deltaCDF=   sumCounts1(1:end-1) -   sumCounts2(1:end-1);
end
clear sumCounts1
clear sumCounts2

KSstatistic   =  max(deltaCDF,[],1);
clear deltaCDF
%
% Compute the asymptotic P-value approximation and accept or
% reject the null hypothesis on the basis of the P-value.
%

%sum(mask1) returns a count of the non-nan elements in each column of x1,
%same for sum(mask2). the result is a row vector of counts
n1     =  sum(mask1);
n2     =  sum(mask2);
n      =  (n1 .* n2) ./(n1 + n2);
lambda =  max(((sqrt(n) + 0.12 + 0.11./sqrt(n)) .* KSstatistic) , 0);

if tail ~= 0        % 1-sided test.

   pValue  =  exp(-2 * lambda .* lambda);

else                % 2-sided test (default).
%
%  Use the asymptotic Q-function to approximate the 2-sided P-value.
%
   j       =  repmat((1:101)',1,c);
   pValue  =  2 * sum(  (-1).^(j-1)     .*  exp(-2*repmat(lambda.*lambda,size(j,1),1).*j.^2));
   pValue  =  min(max(pValue, 0), 1);

end

H  =  (alpha >= pValue);































