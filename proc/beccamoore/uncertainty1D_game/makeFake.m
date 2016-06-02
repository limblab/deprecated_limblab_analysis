close all;

theta=atan2(bdf.vel(1:5000,3),bdf.vel(1:5000,2));

trange = [-180:15:165]*pi/180;
pd = pi/4;

k = 0.10;
b = k+0.05;
tuning = k*cos(trange-pd)+b;
plot(trange,tuning)



for bi=1:length(theta)
    r = rand(1);
    if r<=interp1(trange,tuning,theta(bi))
        spikes(bi) = 1;
    else
        spikes(bi) = 0;
    end
end