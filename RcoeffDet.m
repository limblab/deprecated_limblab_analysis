function r2=RcoeffDet(ypred,yobs)

% syntax r2=RcoeffDet(ypred,yobs);
%
% in the 'ytest' vernacular, yobs=ytest
%
% works for column-wise matrices.

sse=sum(((yobs-ypred).^2));
sstot=var(yobs)*length(yobs);
r2=1-sse./sstot;