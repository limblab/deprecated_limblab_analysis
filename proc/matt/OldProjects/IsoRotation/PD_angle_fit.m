function result = PD_angle_fit(data)

nDirs = length(data);

dirs = [];
fr = [];
for i = 1:nDirs
    fr = [fr; data{i}'];
    dirs = [dirs; (i-1) * 2 * pi / nDirs * ones(size(data{i}'))];
end

%%angle from cosine fit
st = sin(dirs);
ct = cos(dirs);
X = [ones(size(dirs)) st ct];

for iN = 1:length(fr)
    % model is b0+b1*cos(theta)+b2*sin(theta)
    b = regress(fr,X);
    
    % convert to model b0 + b1*cos(theta+b2)
    b  = [b(1); sqrt(b(2).^2 + b(3).^2); atan2(b(2),b(3))];
    
    thetaP(1,1) = b(3);
    thetaP(1,2) = thetaP(1,1)*180/pi;
end



theta= thetaP(1,1);

result = theta;
