
%
% code to take force data (mean and standard deviations), stimulus data and
% compute the maximum likelihood estimate recruitment curve for the data
%
% params = fitMaxLikelihoodRecruitCurve(Y, Sy, X)
%
% params = [Fmax; delta; alpha; beta]
%
% force = Fmax*[delta + (1-delta)/(1 + exp(-alpha*x + beta)]
%
% log( P(force|params) ) = Sum -(Y - force(x))^2/2/Sy^2 
%

function recruitParams = fitMaxLikelihoodRecruitCurve(Y, Sy, X)

n = length(Y);

[m,r] = size(Sy);
if m == 1
    Sy = Sy';
    m = r;
end

if n ~= length(X)
    disp('error with dimensions, Y and X')
    return;
elseif n ~= m
    disp('error with dimensions, Y and Sy')
    return;
end


% global Data Std 

Data(:,1) = Y;
Data(:,2) = X;
Std = Sy;

Fmax = Y(n);
delta = Y(1)/Fmax;
alpha = 1;
beta = 1;

options = optimset('MaxFunEval',10000,'MaxIter',10000,'TolFun',1E-9,...
    'TolX',1E-9,'TolCon',1E-6);

param0 = [Fmax; delta; alpha; beta];

[recruitParams, fval, flag] = fminsearch(@(LL)logLike(LL,Data,Std),param0,options);


if flag == 0
    disp('max num of iterations reached')
elseif flag == -1
    disp('alg terminated by output function?')
elseif flag == 1
    disp('reached tolerance')
end
disp(['exiting with log likelihood of ',num2str(fval)])    



function LL = logLike(params, Data, Std)

% global Data Std

Fmax = params(1);
delta = params(2);
alpha = params(3);
beta = params(4);

force = Fmax * ( delta + (1-delta)./(1 + exp(-alpha*Data(:,2) + beta)) );

LL = sum( (Data(:,1) - force).^2 ./Std.^2 );