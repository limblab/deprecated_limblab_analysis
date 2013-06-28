function [VAF, R2, MSE] = computeStats(preds,real)


% Compute VAF and R2
VAF = 1 - var(preds - real,0,1)./var(real,0,1);
for i = 1:size(real,2)
    R2(i) = 1-sum((preds(:,i)-real(:,i)).^2,1)./sum((preds(:,i) - mean(real(:,i))).^2);
end
MSE = mean((preds-real).^2,1);

end