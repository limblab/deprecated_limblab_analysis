function vaf = CalculateVAF(Sig1,Sig2)

% Sig1: actual measured variable
% Sig2: predicted estimated variable

    numSigs = size(Sig1,2);
  
    vaf = zeros(numSigs,1);
    for i = 1:numSigs
        %Calculate R2
        aux =corrcoef(Sig1(:,i),Sig2(:,i));
        aux = 1 - var(Sig1(:,i)-Sig2(:,i))/var(Sig1(:,i));
        vaf(i)=aux;
        clear aux
    end