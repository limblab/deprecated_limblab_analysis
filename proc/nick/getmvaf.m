function [mvaf] = getmvaf(X,Xhat)
%%Takes in columnwise X Xhat
% 
error = (X-Xhat);

mvaf = 1 - sum(sum(error(:,:).^2))/sum(sum((X(:,:)-repmat(mean(X),size(X,1),1)).^2));
% mvaf = 1 - sum(sum(error(:,:).^2))/sum(sum((X(:,:)-repmat(X(1,:),size(X,1),1)).^2));  