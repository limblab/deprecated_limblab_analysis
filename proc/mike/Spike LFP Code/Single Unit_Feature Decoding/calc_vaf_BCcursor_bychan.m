function [SingleChanVAF] = calc_vaf_BCcursor_bychan(PB, y_test, H, bestc_bychan, bestf_bychan, P)
% x_test = the power within the band being considered
numsides = 1;
binsamprate = 10; %if binsize is .1 seconds.  Otherwise its floor(1/binsize)
if size(P,1) > size(P,2)
    P = P';
end

for i = 1: length(bestc_bychan)
    
    x_test = squeeze(PB(bestf_bychan(i), bestc_bychan(i), :));
    H_feat = H((i-1)*10+1:(i*10),:);
    
    [y_pred{i},xtnew{i},ytnew{i}] = predMIMO3(x_test,H_feat,numsides,binsamprate,y_test);
    
    for z=1:size(y_pred{i},2)
    y_pred{i}(:,z) = P(z,1)*y_pred{i}(:,z).^3 + P(z,2)*y_pred{i}(:,z).^2 +...
        P(z,3)*y_pred{i}(:,z);
    
    y_pred{i}(:,z) = y_pred{i}(:,z) - mean(y_pred{i}(:,z));
    ytnew{i}(:,z) = ytnew{i}(:,z)- mean(ytnew{i}(:,z));
    
    SingleChanVAF(i,:) = RcoeffDet(y_pred{i},ytnew{i}(:,1:size(y_pred{i},2)));
    end
    
end