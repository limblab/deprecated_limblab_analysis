function [n_para, n_perp, H_para_AllLag, H_perp_AllLag, H_para_Allalpha, ...
    H_perp_Allalpha, H_perp_3_4, varargout] = ...
    buildSVDprojdecoders(x, V, y, numlags, numsides, lambda, binsamprate, ...
    varargin)

if isempty(varargin)~=1
    TestRandH = varargin{1};
    if length(varargin)>1
        Rand_I = varargin{2};
    end
end

%% Now start projecting neuron firing rates onto SVD eigen vectors
for vi = 1:length(V)
    if size(x,2) == size(V{vi},1)
        alpha1{vi} = x*V{vi}(:,1);
        alpha2{vi} = x*V{vi}(:,2);
    else
        continue
    end
    
    n_para_temp1 = alpha1{vi};
    n_para_temp2 = alpha2{vi};
    if vi > 1
        n_para(:,vi,1) = [zeros(vi-1,1,1); n_para_temp1(1:end-(vi-1))];
        n_para(:,vi,2) = [zeros(vi-1,1,1); n_para_temp2(1:end-(vi-1))];
    else
        n_para(:,vi,1) = [n_para_temp1(:,1:end-(vi-1))];
        n_para(:,vi,2) = [n_para_temp2(:,1:end-(vi-1))];
    end
    
    clear n_para_temp
    perpInd = 1;
    for ni = 3:size(V{vi},2)
        alpha_n(:,:,perpInd) = x*V{:,vi}(:,ni);
        perpInd = perpInd + 1;
    end
    
    n_perp_temp = alpha_n;
    if vi > 1
        n_perp(:,vi,:) = [zeros(vi-1,1,size(alpha_n,3)); n_perp_temp(1:end-(vi-1),:,:)];
    else
        n_perp(:,vi,:) = [n_perp_temp(1:end-(vi-1),:,:)];
    end
    
    clear n_perp_temp perpInd
end

% %% Now build and test decoders on single lag projections of FR onto V
%
%         [H_para{vi,:},v,mcc] = FILMIMO3_tik(n_para(:,vi), y, numlags, numsides,lambda,binsamprate);
%         [H_perp{vi,:},v,mcc] = FILMIMO3_tik(n_perp(:,vi), y, numlags, numsides,lambda,binsamprate);
%
%         [y_pred_para{vi},xtnew{vi},ytnew_para{vi}] = predMIMO3(n_para(:,vi),H_para{vi,q},numsides,binsamprate,y);
%         [y_pred_perp{vi},xtnew{vi},ytnew_perp{vi}] = predMIMO3(n_perp(:,vi),H_perp{vi,q},numsides,binsamprate,y);
%
%         for j = 1:size(y,2)
%             r_para{vi,:,j}=corrcoef(y_pred_para{vi}(:,j),ytnew_para{vi}(:,j));
%             r{vi,:,j}=corrcoef(y_pred_para{vi}(:,j),ytnew_para{vi}(:,j));
%
%             r_perp{vi,:,j}=corrcoef(y_pred_perp{vi}(:,j),ytnew_perp{vi}(:,j));
%             r{vi,:,j}=corrcoef(y_pred_perp{vi}(:,j),ytnew_perp{vi}(:,j));
%
%             R2_para(vi,:,j)=r_para{vi,q,j}(1,2)^2;
%             R2_perp(vi,:,j)=r_perp{vi,q,j}(1,2)^2;
%         end
%     end
%
%     clear y_* xt* yt* r_* r

%% Now build and test decoders on all lags
n_para_all = reshape(n_para(:,:,1:2),size(n_para,1),size(n_para,2)*2);
n_perp_all = reshape(n_perp,size(n_perp,1),size(n_perp,2)*size(n_perp,3));
n_perp_3_4 = reshape(n_perp(:,:,1:2),size(n_perp,1),size(n_perp,2)*size(n_perp(:,:,1:2),3));

if exist('n_para','var') == 0
    return
elseif exist('TestRandH','var') == 0
    [H_para_AllLag(:,:,1),v,mcc] = FILMIMO3_tik(n_para(:,:,1), y, numlags, numsides,lambda,binsamprate);
    [H_para_AllLag(:,:,2),v,mcc] = FILMIMO3_tik(n_para(:,:,2), y, numlags, numsides,lambda,binsamprate);
    [H_para_AllLag(:,:,3),v,mcc] = FILMIMO3_tik(n_para(:,:,1)+n_para(:,:,2), y, numlags, numsides,lambda,binsamprate);
    [H_para_AllLag(:,:,4),v,mcc] = FILMIMO3_tik(n_para(:,:,1)-n_para(:,:,2), y, numlags, numsides,lambda,binsamprate);
    
    [H_perp_3_4,v,mcc] = FILMIMO3_tik(n_perp_3_4, y, numlags, numsides,lambda,binsamprate);
    for ai = 1:size(n_perp,3)
        [H_perp_AllLag(:,:,ai),v,mcc] = FILMIMO3_tik(n_perp(:,:,ai), y, numlags, numsides,lambda,binsamprate);
    end
    
    [H_para_Allalpha,v,mcc] = FILMIMO3_tik(n_para_all, y, numlags, numsides,lambda,binsamprate);
    [H_perp_Allalpha,v,mcc] = FILMIMO3_tik(n_perp_all, y, numlags, numsides,lambda,binsamprate);
end

if exist('TestRandH','var') == 1
    n_all = zeros(size(x,1),numlags*10,size(x,2));
    n_all(:,:,1:2) = n_para;
    n_all(:,:,3:size(n_perp,3)+2) = n_perp;
    
    parfor r = 1:length(Rand_I)
        n_2_rand = reshape(n_all(:,:,[Rand_I(r,1) Rand_I(r,2)]),size(n_all,1),size(n_all,2)*2);
        ind = 1:size(x,2);
        bia = ismember(ind,Rand_I(r,:));
        ind = ind(~bia);
        n_minus_2_rand = reshape(n_all(:,:,ind),size(n_all,1),size(n_all,2)*size(n_all,3)-20);
        [H_2_rand(:,:,r),v,mcc] = FILMIMO3_tik(n_2_rand, y, numlags, numsides,lambda,binsamprate);
%         [H_n_minus2_rand(:,:,r),v,mcc] = FILMIMO3_tik(n_minus_2_rand, y, numlags, numsides,lambda,binsamprate);
    end
    
    if nargout>6
        varargout{1}=H_2_rand;
        H_para_AllLag = [];
        H_perp_AllLag = [];
        H_para_Allalpha = [];
        H_perp_Allalpha = [];
%         varargout{2}=H_n_minus2_rand;
        if nargout>8
            varargout{3}=Rand_I;
        end
    end
end