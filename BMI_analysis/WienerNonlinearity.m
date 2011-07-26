%%%This function takes some data predicted by a (presumably) linear model
%%%and finds the best fit polynomial between the data 'predicted' by that
%%%model and the actual training data.  This polynomial can be used to
%%%modify the output of the purely linear model as part of a nonlinear
%%%Wiener cascade model
%%
%%%[P] = WienerNonlinearity(Y, Z, N, plotflag)
%%
%%%Y is the data predicted by the original/linear model
%%%Z is the actual recorded training data
%%%N is the order of the nonlinearity to use
%%%plotflag (optional) => 'plot' if you want to generate a plot of the 
%%%Linear vs actual data predictions and the resulting best fit polynomial
%%
%%%Last modified May 2006 EAP
function [P] = WienerNonlinearity(Y, Z, N, plotflag)

if (nargin==3) plotflag=['nopl'];
elseif (nargin ~=4) disp('Wrong number of inputs');return;end
X=Y;

%Fit nonlinearity
%P has the coefficents, starts with highest order first
[P,S] = polyfit(X,Z,N); 

%%%%%%%%%%%%%%%%%
% [P',a,b]=chebfit(X,Z,N);
% nonlinearity=chebval(P',X,a,b);
% [dom,ran]=chebplot(P',a,b);
%%%%%%%%%%%%%%%%%
   
%Plot nonlinearity
if plotflag==['plot']
    %%%Evalute the polynomial using the original fit of the data.
    nonlinearity = polyval(P,Y);
    %%%Plot results
    figure; plot(X,Z,'b.',X,nonlinearity,'g.')    
    xlabel('Original Model Output')
    ylabel('Actual Training Data Values')
end