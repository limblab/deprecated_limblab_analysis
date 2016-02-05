function plot_sigmoid_MLE(params,xIN,vecGood,color)
% params = [Fmax; delta; alpha; beta]

% Add more input current values to xIN
clear xINnew
for jj = 1:size(xIN,2)
    maxV = max(xIN(:,jj));
    minV = min(xIN(:,jj));
    xINnew(:,jj) = minV:lower((maxV-minV)/100):maxV;
end

for ii = 1:size(params,2)
    force = eval_sigmoid_MLE(params(:,ii),xINnew(:,ii));
%     force = params(1,ii)*[params(2,ii) + (1-params(2,ii))./(1 + exp(-params(3,ii)*xINnew(:,ii) + params(4,ii)))];
    figure(vecGood(ii)+10); subplot(2,1,1); hold on;
    plot(xINnew(:,ii),force,'Color',color,'LineStyle','-')
end
