% Preferred Direction estimation of all data w.r.t. time lags/leads.

clear; %close all;
load BinnedData_lowrate;

Kin = kin(:,1:2);   % remove the instantaneous velocity
M = size(Kin,1);    % length of the time steps
Rate = rateM1;    % take either M1 or PMd

% estimate the velocity
Vel = zeros(M,2);
for k = 1:length(TLength)-1
   Vel(TLength(k)+2:TLength(k+1),:) = diff(Kin(TLength(k)+1:TLength(k+1),1:2));
end

theta = atan2(Vel(:,2), Vel(:,1));  % [-pi, pi]
speed = sqrt(sum(Vel.^2,2));

N = 16;  % discretize -pi~pi to N segments   
numCells = size(Rate,2);  % M1: 54 cells, PMd: 50 cells

% consider the time lag
h = 0;
rate = Rate;
MLag = 6;
for Lag = -MLag:MLag
   h = h+1;
   if Lag > 0
       rate(1+Lag:M,:) = Rate(1:M-Lag,:);
   else
       rate(1:M+Lag,:) = Rate(1-Lag:M,:);
   end

   a = (0:N)/N*2*pi-pi;    

   for n = 1:N
       temp = find(theta > a(n) & theta < a(n+1));
       num_sp(n) = length(temp);               % number of sample points in each region
       MFR(n,:) = mean(rate(temp,:));          % mean firing rate
   end

   % fit the parameters z = a + b*cos(theta) + c*sin(theta)
   Q = [ones(N,1), cos(a(2:N+1)'-pi/N), sin(a(2:N+1)'-pi/N)];

   A = pinv(Q)*MFR;
   C(:,:,h) = A(2:3,:)./(ones(2,1)*sqrt(A(2,:).^2+A(3,:).^2)+eps);
   d_c(h,:) = atan2(C(2,:,h),C(1,:,h));

   u = MFR; v = Q*A;
   u = u - ones(N,1)*mean(u,1); v = v - ones(N,1)*mean(v,1);
   cc(:,h) = sum(u.*v,1)'./(sqrt(sum(u.*u,1).*sum(v.*v,1))+eps)';   % correlation coefficient
end    

% plot raw data, cosine fit, and the estimated preferred direction unit vectors
dir_all=[];
x_all=[];
y_all=[];
figure
for k = 1:numCells
   %numCells
   subplot(9,8,k);

   x_part = squeeze(C(1,k,:));
   y_part = squeeze(C(2,k,:));
   %ang=atan2(y_part,x_part)-atan2(y_part(MLag+3),x_part(MLag+3));
   %x_part=cos(ang);
   %y_part=sin(ang);
   %x_all=[x_all;x_part'];
   %y_all=[y_all;y_part'];    
   arrow_plot(x_part,y_part,'r'); hold on;
   arrow_plot(x_part(1:MLag+1),y_part(1:MLag+1),'g');
   arrow_plot(x_part(1:MLag),y_part(1:MLag));

   set(gca,'xtick',[]); set(gca,'ytick',[]);  
   axis equal;
   title(sprintf('cc = %3.2f', mean(cc(k,:))), 'fontsize',10);
end
m=25;
PD_all=[];
for k=1:numCells
       m=m+1;
       if m>25
           figure
           m=1;
       end;
       subplot(5,5,m);
       x_part = squeeze(C(1,k,:));
       y_part = squeeze(C(2,k,:));
       PD=atan2(y_part,x_part);
       PD_all(k,:)=PD;
       for l=length(PD):-1:1
       if (cc(k,l)>=0.5)
       polar(PD(l),l,'r.');
       end;
       hold on;
%        axis([0 14 0 360]);
       title(sprintf('Neuron %i',k));
       end;
end;