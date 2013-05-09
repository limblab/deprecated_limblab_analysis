function [vaf,ytnew,y_pred,bestc,bestf,H,P]=buildModel_ECoG(x,fpind,y,PolynomialOrder,Use_Thresh, ...
    lambda,numlags,numsides,binsamprate,featind,nfeat,varargin)

% predonlyxy_ECoG.m This function runs just the prediction part of predictionsfromfp6.m
% useful once you have x and y matrices to run different levels of lambda


Hinpflag=0;     %Whether H is input or not

if ~isempty(varargin)
    smoothflag=varargin{1};
    if length(varargin)>1
        featShift=varargin{2};
    else
        featShift=0;
%         H=varargin{2};
%         Hinpflag=1;
%         if length(varargin)>2
%             P=varargin{3};
%             if length(varargin)>3
%                 smoothflag=varargin{4};
%             end
%         end
    end
end
if ~exist('smoothflag','var')
    smoothflag=0;
end
% Smoothing.  Do causal only, to better mimic the online case.
x_smoothed=zeros(size(x));
if smoothflag
    if smoothflag>10
        for n=10:(smoothflag-1)
            x_smoothed(n,:)=mean(x(1:n,:),1);
        end
    end
    for n=smoothflag:size(x,1)
        x_smoothed(n,:)=mean(x((n-smoothflag+1):n,:),1);
    end
    x=x_smoothed;
    % skip y smoothing for now
%     ytemp=y(:);
%     ytemp=smooth(y(:),50,'sgolay');
%     y=reshape(ytemp,size(y));
end

% if column 1 is monotonically increasing then it is the time vector.
if nnz(diff(y(:,1))<0)==0
    analog_times=y(:,1);
    y(:,1)=[];
end

if exist('featind','var')~=1
    for f=1:size(x,2)
        rt1=corrcoef(y(:,1),x(:,f));
        if size(y,2)>1                  %%%%% NOTE: MODIFIED THIS 1/10/11 to use ALL outputs in calculating bestfeat (orig modified 12/13/10 for 2 outputs)
            rsum=abs(rt1);
            for n=2:size(y,2)
                rtemp=corrcoef(y(:,n),x(:,f));
                rsum=rsum+abs(rtemp);
            end
            rt=rsum/n;
        else
            rt=abs(rt1);    %take absolute value of r
        end
        r(f)=rt(1,2);
    end
    % since r is an average, there is no need to reshape it; it will just be a
    % vector anyway.
    [sr,featind]=sort(r,'descend');
end

[bestf,bestc]=ind2sub([6 length(fpind)],featind((1:nfeat)+featShift));
x=x(:,featind((1:nfeat)+featShift));
figure, plot(mean(abs(x))), xlabel('feature number')
title(sprintf(['mean raw values: if there is a large discrepancy at the far right side,\n',...
    'too many features are being included (currently nfeat =%d)'],nfeat))
% recast in channel order.
bestcf=[rowBoat(bestc), rowBoat(bestf)];
[temp,sortInd]=sortrows(bestcf);
% the default operation of sortrows is to sort first on column 1, then do a
% secondary sort on column 2, which is exactly what we want, so we're done.
x=x(:,sortInd);
bestc=temp(:,1)';
bestf=temp(:,2)';
clear r

    
if ~exist('H','var')
    [H,v,junk] = FILMIMO3_tik(x,y,numlags,numsides,lambda,binsamprate);
end
[y_pred,xtnew,ytnew]=predMIMO3(x,H,numsides,binsamprate,y);

P=[];
T=[];
patch = [];

if PolynomialOrder
    %%%Find a Wiener Cascade Nonlinearity
    for z=1:size(y_pred,2)
        if Use_Thresh
            %Find Threshold
            T_default = 1.25*std(y_pred(:,z));
            [T(z,1), T(z,2), patch(z)] = findThresh(ytnew(:,z),y_pred(:,z),T_default);
            IncludedDataPoints = or(y_pred(:,z)>=T(z,2),y_pred(:,z)<=T(z,1));

            %Apply Threshold to linear predictions and Actual Data
            PredictedData_Thresh = y_pred(IncludedDataPoints,z);
            ActualData_Thresh = y_tnew(IncludedDataPoints,z);

            %Replace thresholded data with patches consisting of 1/3 of the data to find the polynomial
            Pred_patches = [ (patch(z)+(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ...
                (patch(z)-(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ];
            Act_patches = mean(ytnew(~IncludedDataPoints,z)) * ones(1,length(Pred_patches));

            %Find Polynomial to Thresholded Data
            [P(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%% Use only one of the following 2 lines:
            %
            %   1-Use the threshold only to find polynomial, but not in the model data
            T=[]; patch=[];
            %
            %   2-Use the threshold both for the polynomial and to replace low predictions by the predefined value
            %                 y_pred{i}(~IncludedDataPoints,z)= patch(z);
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif ~exist('P','var') || size(P,1)<z
            %Find and apply polynomial if it hasn't been input already
            [P(z,:)]=WienerNonlinearity(y_pred(:,z),ytnew(:,z),PolynomialOrder);
        end
        y_pred(:,z)=polyval(P(z,:),y_pred(:,z));
    end
end

% old way
% vaf(i,:) = 1 - var(y_pred{i} - ytnew{i}) ./ var(ytnew{i});
% new way
vaf=RcoeffDet(y_pred,ytnew);

for j=1:size(y,2)
    r{j}=corrcoef(y_pred(:,j),ytnew(:,j));
    if size(r{j},2)>1
        r2(j)=r{j}(1,2)^2;
    else
        r2(j)=r{j}^2;
    end
end

    function [Tinf, Tsup, patch] = findThresh(ActualData,LinPred,T)

        thresholding = 1;
        h = figure;
        xT = [0 length(LinPred)];
        offset = mean(LinPred)-mean(ActualData);
        LinPred = LinPred-offset;
        Tsup=mean(LinPred)+T;
        Tinf=mean(LinPred)-T;
        patch = mean(ActualData);

        while thresholding
            hold off; axis('auto');
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine High Threshold? [%g] : ',Tsup));
            if ~isempty(reply)
                Tsup = reply;
            else
                thresholding=0;
            end
        end
        thresholding=1;
        while thresholding
            axis('auto');
            hold off;
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine Low Threshold? [%g] : ',Tinf));
            if ~isempty(reply)
                Tinf = reply;
            else
                thresholding=0;
            end
        end
        thresholding=1;
        while thresholding
            axis('auto');
            hold off;
            plot(ActualData,'b');
            hold on;
            plot(LinPred,'r');
            plot(xT,[Tsup Tsup],'k--',xT,[Tinf Tinf],'k--', xT,[patch patch],'g');
            legend('Actual Data', 'Linear Fit','Threshold');
            axis('manual');
            reply = input(sprintf('Redefine Threshold Value? [%g] : ',patch));
            if ~isempty(reply)
                patch = reply;
            else
                thresholding=0;
            end
        end
        Tsup = Tsup+offset;
        Tinf = Tinf+offset;
        patch = patch+offset;

        close(h);
    end

end
