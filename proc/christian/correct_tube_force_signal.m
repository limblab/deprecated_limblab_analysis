function Fcorr = correct_tube_force_signal(t_F,F)

% t_F = timeframe for force signal
% F   = tube force signal with drift that needs to be corrected


LP = 5; % 5Hz
SR = round(1/(t_F(2)-t_F(1)));
[b,a] = butter(4,LP*2/SR,'low');

dF = [0; diff(F)];
dFS= filtfilt(b,a,abs(dF));
tol = std(dFS);
wmin = 0.5*SR; % 500ms min between beginning of 2 squeezes, otherwise concatenate
wmean = 0.5*SR; % 500ms the averaging window for detection of state transition.

%% Find Squeeze vs Rest Periods
thresh = find( (dFS(2:end) > tol) & (dFS(1:end-1)<tol));

squeeze_start = thresh(1);
for i = 2:length(thresh)
    if mean(dFS(max(1,thresh(i)-wmean):thresh(i))) <tol && ...
       mean(dFS(thresh(i):min(length(dFS),thresh(i)+wmean)))>tol && ...
       thresh(i) > squeeze_start(end)+wmin && ...
       mean( F(max(1,thresh(i)-wmean):thresh(i))) < std(F)
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
    thresh = find(intra_sq(2:end) < tol & intra_sq(1:end-1)>tol);
    for j = length(thresh):-1:1
        % have to choose the last thresh that fits criterion
        % otherwise may discard some data
        Fidx = squeeze_start(i)+thresh(j);
        if mean( dFS(max(1,Fidx-wmean):Fidx)) > tol && ...
           mean( dFS(Fidx:min(length(dFS),Fidx+wmean))) < tol
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

%% Correct with linear approximation
Fcorr = zeros(size(F));
for i = 1:length(squeeze_start)
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
%remove negative force values if any
Fcorr(Fcorr<0) = 0;

figure;
hold on;
plot(t_F,F,'b');plot(t_F,Fcorr,'k');
for i = 1:(length(squeeze_start))
    xx = [t_F(squeeze_start(i)) t_F(rest_start(i+1))];
    top = [max(F) max(F)];
    bottom = min(F);
    area(xx,top,bottom,'FaceColor',[0.7 0.7 0.7],'Linestyle','none');    
end
plot(t_F,F,'b');plot(t_F,Fcorr,'k');
legend('Force Orig','Force Corrected');


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
