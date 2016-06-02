function R2 = CalculateR2(Sig1,Sig2)

    numSigs = size(Sig1,2);
  
    R2 = zeros(numSigs,1);
    for i = 1:numSigs
        %Calculate R2
        R=corrcoef(Sig1(:,i),Sig2(:,i));
        R2(i)=R(1,2).^2;
        clear R
    end