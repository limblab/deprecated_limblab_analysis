function getAdaptationMetrics(bdf)
% Get correlation over time

% identify individual movements by threshold of 3.2cm/s
vThresh = 3.2; %cm/s

t = bdf.vel(:,1);
vx = bdf.vel(:,2);
vy = bdf.vel(:,3);

dvx = diff(vx);
dvy = diff(vy);
ddvx = diff(dvx);
ddvy = diff(dvy);

t = t(3:end);
vx = vx(3:end);
vy = vy(3:end);
dvx = dvx(2:end);
dvy = dvy(2:end);

k = (dvx.*ddvy - ddvx.*dvy)./((dvx.^2+dvy.^2).^(3/2));
k(abs(k)>1e5) = 1e5;

% Break into chunks
n=120000;
bins = 1:n:length(k);

for i = 1:length(bins)-1
    bk_m(i) = mean(k(bins(i):bins(i+1)-1));
    bk_s(i) = std(k(bins(i):bins(i+1)-1));
end

figure;
hold all;
plot(bk_m,'kd')
plot(bk_m+bk_s,'k+')
plot(bk_m-bk_s,'k+')
keyboard
% figure;
% subplot1(4,1);
% subplot1(1);
% plot(t,k);
% subplot1(2);
% hold all;
% plot(t,vx);
% plot(t,vy);
% subplot1(3);
% hold all;
% plot(t,dvx);
% plot(t,dvy);
% subplot1(4);
% hold all;
% plot(t,ddvx);
% plot(t,ddvy);
