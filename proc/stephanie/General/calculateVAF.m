function VAF = calculateVAF(Pred,Act)
VAF = 1 - sum( (Pred-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2 );
end