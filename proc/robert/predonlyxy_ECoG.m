function [vaf,ytnew,y_pred,bestc,bestf,featind,H,P]=predonlyxy_ECoG(x,fpind,y,PolynomialOrder,Use_Thresh,lambda,numlags,numsides,binsamprate,folds,nfeat,varargin)

% predonlyxy_ECoG.m This function runs just the prediction part of predictionsfromfp6.m
% useful once you have x and y matrices to run different levels of lambda



% H are the filters
fold_length = floor(length(y) ./ folds);

Hinpflag=0;     %Whether H is input or not

if ~isempty(varargin)
    smoothflag=varargin{1};
    if length(varargin)>1
        featShift=varargin{2};
    else
        featShift=0;
    end
    %     bestf_old=varargin{1};
    %     bestc_old=varargin{2};
%     if length(varargin)>2
%         H=varargin{3};
%         Hinpflag=1;
%         if length(varargin)>3
%             P=varargin{4};
%         end
%     end
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
featind(isnan(sr))=[];
r(isnan(r))=[];
assignin('base','R',r)
[bestf,bestc]=ind2sub([length(featind)/length(fpind) length(fpind)], ...
    featind((1:nfeat)+featShift));
x=x(:,featind((1:nfeat)+featShift));
figure, plot(mean(abs(x))), xlabel('feature number')
title(sprintf(['mean raw values: if there is a large discrepancy at the far right side,\n',...
    'too many features are being included (currently nfeat =%d)'],nfeat))
% reorder x so that it's cast back into the arrangemnt in which it will
% ultimately be evaluated online: that of cells and bands.
bestcf=[rowBoat(bestc), rowBoat(bestf)];
[temp,sortInd]=sortrows(bestcf);
% the default operation of sortrows is to sort first on column 1, then do a
% secondary sort on column 2, which is exactly what we want, so we're done.
x=x(:,sortInd);
bestc=temp(:,1)';
bestf=temp(:,2)';
clear r

x_test=cell(folds,1);
y_test=x_test;
y_pred=y_test;
P=[];
fprintf(1,'fold ')
for i = 1:folds
    fold_start = (i-1) * fold_length + 1;
    fold_end = fold_start + fold_length-1;
    
    x_test{i} = x(fold_start:fold_end,:);
    y_test{i} = y(fold_start:fold_end,:);
    
    x_train = [x(1:fold_start,:); x(fold_end:end,:)];
    y_train = [y(1:fold_start,:); y(fold_end:end,:)];
    
    if ~exist('H','var') || length(H)<i
        [H{i},v,junk] = FILMIMO3_tik(x_train, y_train, numlags, numsides,lambda,binsamprate);
		fprintf(1,'%d,',i)
    end
    
    [y_pred{i},xtnew{i},ytnew{i}] = predMIMO3(x_test{i},H{i},numsides,binsamprate,y_test{i});
    
    T=[];
    patch = [];
    
    if PolynomialOrder
        %%%Find a Wiener Cascade Nonlinearity
        for z=1:size(y_pred{i},2)
            if Use_Thresh
                %Find Threshold
                T_default = 1.25*std(y_pred{i}(:,z));
                [T(z,1), T(z,2), patch(z)] = findThresh(y_test{i}(:,z),y_pred{i}(:,z),T_default);
                IncludedDataPoints = or(y_pred{i}(:,z)>=T(z,2),y_pred{i}(:,z)<=T(z,1));
                
                %Apply Threshold to linear predictions and Actual Data
                PredictedData_Thresh = y_pred{i}(IncludedDataPoints,z);
                ActualData_Thresh = y_test{i}(IncludedDataPoints,z);
                
                %Replace thresholded data with patches consisting of 1/3 of the data to find the polynomial
                Pred_patches = [ (patch(z)+(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ...
                    (patch(z)-(T(z,2)-T(z,1))/4)*ones(1,round(length(nonzeros(IncludedDataPoints))*4)) ];
                Act_patches = mean(y_test{i}(~IncludedDataPoints,z)) * ones(1,length(Pred_patches));
                
                %Find Polynomial to Thresholded Data
                [P{i}(z,:)] = WienerNonlinearity([PredictedData_Thresh; Pred_patches'], [ActualData_Thresh; Act_patches'], PolynomialOrder,'plot');
                
                
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
            else%if ~exist('P','var') || size(P,1)<z
                %Find and apply polynomial if it hasn't been input already
                ws=warning('off','all');
                [P{i}(z,:)] = WienerNonlinearity(y_pred{i}(:,z), ytnew{i}(:,z), PolynomialOrder);
                warning(ws)
            end
            y_pred{i}(:,z) = polyval(P{i}(z,:),y_pred{i}(:,z));
        end
    end
    
    %     vaf(i,:) = 1 - var(y_pred{i} - y_test{i}) ./ var(y_test{i});
    if ~Hinpflag
        vaftr(i,:)=v/100; %Divide by 100 because v is in percent
	end
	% old way
    % vaf(i,:) = 1 - var(y_pred{i} - ytnew{i}) ./ var(ytnew{i});
	% new way
	vaf(i,:) = RcoeffDet(y_pred{i},ytnew{i});

    for j=1:size(y,2)
        r{i,j}=corrcoef(y_pred{i}(:,j),ytnew{i}(:,j));
        if size(r{i,j},2)>1
            r2(i,j)=r{i,j}(1,2)^2;
        else
            r2(i,j)=r{i,j}^2;
        end
    end   %
    
end
disp('5th part: do predictions')

%Calculate means
if (vaf(9,1)-vaf(10,1))>0.5
    vmean=mean(vaf(1:9,:));
    vsd=std(vaf(1:9,:),0,1);
else
    vmean=mean(vaf);
    vsd=std(vaf,0,1);
end

if ~Hinpflag
    vaftrm=mean(vaftr);
else
    vaftr=[];
end

if (r2(9,1)-r2(10,1))>0.5    %if big disparity in last fold, don't include it in mean
    r2mean=mean(r2(1:9,:));
    r2sd=std(r2(1:9,:));
else
    r2mean=mean(r2);
    r2sd=std(r2);
end

% Outputs
if nargout>8
    varargout{1}=ytnew;
    if nargout>9
        varargout{2}=xtnew;
        if nargout>10
            varargout{3}=H;
            if nargout>11
                varargout{4}=P;
                if nargout>12
                    %                     if  exist('bestf_old','var')
                    varargout{5}=featind;
                    %                     varargout{6}=bestc;
                    %                     if nargout>14
                    %                        varargout{7}= featind;     %sort index, helps to figure out which features are saved
                    %                     end
                    %                     else
                    %                         varargout{5}='ERROR: Can''t give bestf or bestc since they weren''t input in the first place';
                    %                         varargout{6}='ERROR: Can''t give bestf or bestc since they weren''t input in the first place';
                    %                     end
					if nargout>13
						varargout{6}=vsd;
					end
                end
            end
        end
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