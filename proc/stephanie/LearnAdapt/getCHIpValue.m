function pval = getCHIpValue(SuccessPoints,TrialsPerEpoch)
FirstPercentSuccess= SuccessPoints(1); % get percent success for the first TrialsPerEpoch many trials
LastPercentSuccess= SuccessPoints(end); % get percent success for the last TrialsPerEpoch many trials
n1 = FirstPercentSuccess*TrialsPerEpoch; N1 = TrialsPerEpoch;
  n2 = LastPercentSuccess*TrialsPerEpoch; N2 = TrialsPerEpoch;    
       x1 = [repmat('premierepoch',N1,1); repmat('dernierepoch',N2,1)];
       %'x2' structure: 1s for success trial in epoch 1, 0s for failure in epoch 1, 1s for
       %success in epoch 2, 0s for failure in epoch 2
       x2 = [repmat(1,n1,1); repmat(0,N1-n1,1); repmat(1,n2,1); repmat(0,N2-n2,1)]; 
       [~,~,pval] = crosstab(x1,x2); 
       %crosstab format is [premierepoch,0  prepoch,1
                          % dermierepoch,0  
       
end