%GeneralizableSVDanalysis
function [U, S, V] = GeneralizableSVDanalysis(H)

% input is H;
[U,S,V] = svd(H'); % Use the transpose of H, your filter

% Get your lambdas from the S matrix
for i=1:length(S(:,1))
    lambdas(i) = S(i,i);
    LambdaSubset(i) = sum(lambdas(1:i));
end

% Plot VAFs as a function of number of lambda
x = 1:1:length(lambdas); % xaxis representing the number of lambdas
LambdaSum = sum(lambdas);
LambdaVAFs = LambdaSubset/LambdaSum;
figure; hold on; title('VAFs as a function of #s of lambda');
plot(x,LambdaVAFs,'k*','MarkerSize',10)
plot(2,LambdaVAFs(2),'m*','MarkerSize',10)
str1 = strcat(['\leftarrow ' sprintf('%.2f',LambdaVAFs(2))]);
text(2.2,LambdaVAFs(2),str1);
MillerFigure

% Plot Lambdas
figure; plot(x,lambdas,'k*','MarkerSize',10);
title('Lambda values'); MillerFigure

% Calculate measured modes
% ActualMuscles_Hyb = HybridFinal.emgdatabin;
% UnitVector1 = U(:,1); UnitVector2 = U(:,2);
% MeasuredMode1_Hyb = ActualMuscles_Hyb*UnitVector1;
% MeasuredMode2_Hyb = ActualMuscles_Hyb*UnitVector2;

end