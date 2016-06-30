function sigParams = fit_sigmoid(magF,param)

%% Fit recruitment curve data to sigmoids.
s = fitoptions('Method','NonlinearLeastSquares',...
               'Startpoint',[0 0 0 0]);
f = fittype('Fm*(D+(1-D)./(1 + exp(-A*x+B)))','independent','x','coefficients',{'Fm','D','A','B'},'options',s);

sigParams = zeros(4,size(magF,2));
% fOut = zeros(size(param,1),size(magF,2));
for ii = 1:size(magF,2)
    cOUT = fit(param(:,ii),magF(:,ii),f);
    sigParams(1,ii) = cOUT.Fm;
    sigParams(2,ii) = cOUT.D;
    sigParams(3,ii) = cOUT.A;
    sigParams(4,ii) = cOUT.B;
    
%     fOut(:,ii) = eval_sigmoid_fit(cOUT,param(:,ii));
end