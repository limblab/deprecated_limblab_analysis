function result = PD_angle_calc(data)

nDirs = length(data);
dirs = (0:nDirs-1) * 2 * pi / nDirs;

avgRates = zeros(1,nDirs);
for i = 1:nDirs
    avgRates(i) = mean(data{i});
end

%%angle from cosine fit
b0(1,1)=mean(avgRates);
b(1,1)=(((avgRates(1,2)+avgRates(1,4)-avgRates(1,6)-avgRates(1,8))/sqrt(2))+(avgRates(1,3)-avgRates(1,7)))/4;
b(1,2)=(((avgRates(1,2)-avgRates(1,4)-avgRates(1,6)+avgRates(1,8))/sqrt(2))+(avgRates(1,1)-avgRates(1,5)))/4;
thetaP(1,1)=atan2(b(1,1),b(1,2)); %in radians
thetaP(1,2)=thetaP(1,1)*180/pi;



% %%angle from cosine fit
% for i=1:length(avgRates)
%     b0(i,1)=mean(avgRates(i,:));
%     b(i,1)=(((avgRates(i,2)+avgRates(i,4)-avgRates(i,6)-avgRates(i,8))/sqrt(2))+(avgRates(i,3)-avgRates(i,7)))/4;
%     b(i,2)=(((avgRates(i,2)-avgRates(i,4)-avgRates(i,6)+avgRates(i,8))/sqrt(2))+(avgRates(i,1)-avgRates(i,5)))/4;
%     thetaP(i,1)=atan(b(i,1)/b(i,2)); %in radians
%     thetaP(i,2)=thetaP(i,1)*180/pi;
% end
%% R2
% for i=1:length(avgRates)
%     R2num(i,1)=4*(b(i,1)^2 + b(i,2)^2);
%     R2den(i,1)=(avgRates(i,1)-b0(i,1))^2+(avgRates(i,2)-b0(i,1))^2+(avgRates(i,3)-b0(i,1))^2+(avgRates(i,4)-b0(i,1))^2+(avgRates(i,5)-b0(i,1))^2+(avgRates(i,6)-b0(i,1))^2+(avgRates(i,7)-b0(i,1))^2+(avgRates(i,8)-b0(i,1))^2;
%     R2(i,1)=R2num(i,1)/R2den(i,1);
% end
%% getting angle in right quad

%     if b(1,1)>0 & b(1,2)>0
%         theta(1,1)=thetaP(1,2);
%
%     elseif b(1,2)<0
%         theta(1,1)=thetaP(1,2)+180;
%
%     elseif b(1,1)<0 & b(1,2)>0
%         theta(1,1)=thetaP(1,2)+360;
%     end


theta= thetaP(1,1);

result = theta;
