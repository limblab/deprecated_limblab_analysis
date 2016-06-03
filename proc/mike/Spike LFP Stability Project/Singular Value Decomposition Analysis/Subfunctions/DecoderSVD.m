% SVD analysis on decoders

Numlags = 10; % ***this assumes there are 10 time lags***
findCommonCh = 0;

H1 = reshape(H(:,1:2),1,Numlags,(size(H,1)/Numlags)*2);
% Reshape H so that columns = lag (lag 1 = col 1), and 3rd dim = neuron
% (i.e. 1 layer = 1st neuron).  If N = num neurons the first N layers = the 
% X-velocity weights across all lags and the subsequent N layers (N+1:2*N)=
% the Y-velocity weights across all lags.

for i = 1:size(H1,2)
    Hx = squeeze(H1(:,i,1:size(H1,3)/2));
    Hy = squeeze(H1(:,i,size(H1,3)/2+1:end));
    Htemp = [Hx Hy];
    Hstruct.(['Lag',num2str(i)]) = Htemp;
    [Vtemp,S_T,U_T] = svd(Hstruct.(['Lag',num2str(i)]));
    V{i} = Vtemp;
    V12{i} = Vtemp(:,1:2);
    U{i} = U_T';
    S{i} = S_T';
    SingV = V{i}*S_T;
%     ParticipationNum(:,i) = sqrt(SingV(:,1).^2 + SingV(:,2).^2);
end

clear Numlags Hx Hy Htemp Hstruct i H1 S_T U_T Vtemp

%% Find and plot common channels
if findCommonCh == 1
    
    AvgWeight = mean(ParticpationNum,2)
    AvgWeight = [AvgWeight neuronIDs(:,1)]
    AvgWeightSorted = sortrows(AvgWeight,-1);
    AvgWeightSorted_Norm = AvgWeightSorted(:,1)/max(AvgWeightSorted(:,1))
    
    [CommonCh]= intersect(AvgWeightSorted(1:20,2),Mini_shuntedCh,'rows')
    
    r2_norm = nanmean(r2,2)/max(nanmean(r2,2))'
    
    figure
    plot(AvgWeightSorted_Norm)
    hold on
    plot(r2_norm,'r')
    
    [CommonCh iW iC]= intersect(AvgWeightSorted(1:20,2),bestcSpike(1:20,1),'rows')
    
    hold on
    plot(repmat(iW',2,1),repmat([2 0]',1,length(iW)),'b--')
    
    hold on
    plot(repmat(iC',2,1),repmat([1 0]',1,length(iW)),'r--')
    
    legend('Participation Weight','R^2 Weight')
    
end

clear AvgWeight findCommonCh


