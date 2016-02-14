function [SingleChanVAF r2] = calc_vaf_BCcursor_bychan(PB, y_test, H, bestc_bychan, bestf_bychan, P, y_pred_AllFeat)
% x_test = the power within the band being considered
numsides = 1;
binsamprate = 1; %***This parameter is important, need to use same binsamprate that the
                 % decoder H was built on, which in Robert's code is 1.
if size(P,1) > size(P,2)
    P = P';
end

y_pred = cell(length(bestc_bychan),1);
xtnew = cell(length(bestc_bychan),1);
ytnew = cell(length(bestc_bychan),1);

for i = 1:length(bestc_bychan)
    
    x_test = squeeze(PB(bestf_bychan(i), bestc_bychan(i), :));
    %x_test = x_test';

    H_feat = H((i-1)*10+1:(i*10),:);
    
    if size(x_test,1) < size(y_test,1)
        y_test = y_test(1:length(x_test));
    end
    
    [y_pred{i},xtnew{i},ytnew{i}] = predMIMO3(x_test,H_feat,numsides,binsamprate,y_test);
    
    for z=1:size(y_pred{i},2)
    y_pred{i}(:,z) = P(z,1)*y_pred{i}(:,z).^3 + P(z,2)*y_pred{i}(:,z).^2 +...
        P(z,3)*y_pred{i}(:,z);
    
    y_pred{i}(:,z) = y_pred{i}(:,z) - mean(y_pred{i}(:,z));
    ytnew{i}(:,z) = ytnew{i}(:,z)- mean(ytnew{i}(:,z));
    end
    
    SingleChanVAF(i,:) = RcoeffDet(y_pred_AllFeat,y_pred{i});
    
    for j=1:size(y_pred_AllFeat,2)
        r=corrcoef(y_pred_AllFeat(:,j),y_pred{i}(:,j));
        if size(r,2)>1
            r2(i,j)=r(1,2)^2;
        else
            r2(i,j)=r{i,j}^2;
        end
    end
    
 %   r(i,:)=corrcoef(y_pred_AllFeat,ytnew{i});
    
    clear x_test
    
end

end