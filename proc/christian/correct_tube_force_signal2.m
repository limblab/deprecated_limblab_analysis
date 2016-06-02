function Fcorr = correct_tube_force_signal(t_F,F)

LP = 5; % 5Hz
SR = round(1/(t_F(2)-t_F(1)));
[b,a] = butter(4,LP*2/SR,'low');

dF = [0; diff(F)];
dFS= filtfilt(b,a,abs(dF));
tol = std(dFS)/5;

%% Find Squeeze vs Rest Periods
thresh = find( (dFS(2:end) > tol) & (dFS(1:end-1)<tol));

squeeze_start = thresh(1);
for i = 2:length(thresh)
    if mean(dFS(max(1,thresh(i)-20):thresh(i))) <tol && ...
       mean(dFS(thresh(i):min(length(dFS),thresh(i)+20)))>tol && ...
       thresh(i) > squeeze_start(end)+30
        squeeze_start = [squeeze_start; thresh(i)];
    end
end

rest_start = 1;
for i = 1:length(squeeze_start)
    if i == length(squeeze_start)
        intra_sq = dFS(squeeze_start(i):end);
    else
        intra_sq = dFS(squeeze_start(i):squeeze_start(i+1));
    end
    thresh = find(intra_sq(2:end-10) < tol & intra_sq(1:end-11)>tol);
    for j = 1:length(thresh)
        Fidx = squeeze_start(i)+thresh(j);
        if mean( dFS(max(1,Fidx-20):Fidx)) > tol && ...
           mean( dFS(Fidx:min(length(dFS),Fidx+20))) < tol
            rest_start = [rest_start; Fidx];
            break;
        end
    end
    if length(rest_start)~=i+1
        %could not find a rest_start, use last index of interval or end of data file:
        if i < length(squeeze_start)
            rest_start = [rest_start; squeeze_start(i+1)-1];
        else
            rest_start = [rest_start; length(dFS)];
        end
    end
end

figure;
hold on;
for i = 1:(length(squeeze_start))
    xx = [t_F(squeeze_start(i)) t_F(rest_start(i+1))];
    top = [2 2];
    bottom = -0.5;
    area(xx,top,bottom,'FaceColor',[0.6 0.6 0.6],'Linestyle','none');    
end
plot(t_F,F,'b');
plot(t_F,dFS,'g');

%% Correct with linear approximation
Fcorr = zeros(size(F));
for i = 1:length(squeeze_start)-1
    ydata =   F(squeeze_start(i):rest_start(i+1));
    xdata = t_F(squeeze_start(i):rest_start(i+1));
%     if squeeze_start(i)> (276*20) && squeeze_start(i) <280*20
%         figure;plot(xdata,ydata);
%     end
    m = (ydata(end)-ydata(1))/(xdata(end)-xdata(1));
    ycorr = m*(xdata-xdata(1))+ydata(1);
    ydata = ydata - ycorr;
    Fcorr(squeeze_start(i):rest_start(i+1)) = ydata;
%     if squeeze_start(i)> (276*20) && squeeze_start(i) <280*20
%         hold on;plot(xdata,ydata,'k');plot(xdata,ycorr,'r');
%     end  
end
    
hold on; plot(t_F,Fcorr,'k');legend('Force Orig','smooth(abs(dF))','Force Corrected');


%% Exponential approximation ?
% fitopts = fitoptions('Method','NonlinearLeastSquares',...
%     'Lower',[-100,-100], 'Upper',[100,100],...
%     'Startpoint',[1,1],'MaxFunEvals',2000);
% 
% f = fittype('a*exp(b*x)','options',fitopts);
% for i = 1:length(rest_start)-1
%     xdata = t_F( (rest_start(i):squeeze_start(i))) - t_F(rest_start(i));
%     ydata = F( (rest_start(i):squeeze_start(i)) ) ;
%     fitexp = fit(xdata,ydata,f);
%     a(i) = fitexp.a;
%     b(i) = fitexp.b;
%     yfit = fitexp(xdata);
%     figure;
%     plot(xdata,ydata); hold on;
%     plot(xdata,yfit,'g.');
% end
% 
% x = 0.1:0.1:100;
% y = -0.25*exp(-0.15*x);
% figure; plot(x,y);
% idx=find(y > min(y)+0.63*range(y),1,'first');
% RC= 0.1*idx;
