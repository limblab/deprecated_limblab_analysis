function [r2 vaf mse] = getvaf(X,Xhat)
%%Takes in columnwise X Xhat
% 
X = X';
Xhat = Xhat';

[m n] = size(X);
%  error = (detrend(X','constant')-detrend(Xhat','constant'))';
 error = (X'-Xhat')';

for i = 1:m
    temp = corrcoef(X(i,:),Xhat(i,:));
r2(i) = temp(2,1)^2;

  vaf(i) = 1 - sum(error(i,:).^2)/sum(detrend(X(i,:)','constant').^2);

 
 mse(i) = mean((X(i,:)-Xhat(i,:)).^2);
end
    
    

  