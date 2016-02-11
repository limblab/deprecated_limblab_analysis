function [y_pred] = calc_vaf_BCcursor_All(PB, y_test, H, bestc_bychan, bestf_bychan, P)
% x_test = the power within the band being considered
numsides = 1;
binsamprate = 1; %***This parameter is important, need to use same binsamprate that the
                 % decoder H was built on, which in Robert's code is 1.
if size(P,1) > size(P,2)
    P = P';
end

for i = 1:length(bestc_bychan)
    
    x_test(:,i) = squeeze(PB(bestf_bychan(i), bestc_bychan(i), :));
    %x_test = x_test';
end
    H_feat = H;%((i-1)*10+1:(i*10),:);
    
    if size(x_test,1) < size(y_test,1)
        y_test = y_test(1:length(x_test));
    end
    
    [y_pred{1},xtnew{1},ytnew{1}] = predMIMO3(x_test,H_feat,numsides,binsamprate,y_test);
    
    for z=1:size(y_pred{1},2)
    y_pred{1}(:,z) = P(z,1)*y_pred{1}(:,z).^3 + P(z,2)*y_pred{1}(:,z).^2 +...
        P(z,3)*y_pred{1}(:,z);
    
    y_pred{1}(:,z) = y_pred{1}(:,z) - mean(y_pred{1}(:,z));
    ytnew{1}(:,z) = ytnew{1}(:,z)- mean(ytnew{1}(:,z));
    end
    
%    SingleChanVAF(1,:) = RcoeffDet(y_pred{1}(1:1200),ytnew{1}(1:1200));
    
    clear x_test
    
end