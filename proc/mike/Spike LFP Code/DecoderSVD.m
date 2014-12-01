% SVD analysis on decoders

Numlags = 10; % ***this assumes there are 10 time lags***

H1 = reshape(H(:,1:2),1,Numlags,(size(H,1)/Numlags)*2)
% Reshape H so that columns = lag (lag 1 = col 1), and 3rd dim = neuron
% (i.e. 1 layer = 1st neuron).  If N = num neurons the first N layers = the 
% X-velocity weights across all lags and the subsequent N layers (N+1:2*N)=
% the Y-velocity weights across all lags.

for i = 1:size(H1,2)
    Hx = squeeze(H1(:,i,1:size(H1,3)/2));
    Hy = squeeze(H1(:,i,size(H1,3)/2+1:end));
    Htemp = [Hx Hy];
    Hstruct.(['Lag',num2str(i)]) = Htemp;
    [U,S,V] = svd(Hstruct.(['Lag',num2str(i)]))
    SingV = U*S;
    EuclWeight(:,i) = sqrt(SingV(:,1).^2 + SingV(:,2).^2)
end

AvgWeight = mean(EuclWeight,2)
AvgWeight = [AvgWeight neuronIDs(:,1)]
AvgWeightSorted = sortrows(AvgWeight,-1);