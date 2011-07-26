figure;
hold on;
% 
% gray_shades = [0.75 0.55 0.4 0.2 0];
% gray = repmat(gray_shades,1,3);

numFits = length(Fits);

x = (0:0.001:2)';
xx = [x; x(end:-1:1)];

for i = 1:numFits
    ybot = x*CI{1,i}(1,1);
    ytop = x*CI{1,i}(2,1);
    yy = [ybot; ytop(end:-1:1,:)];
    area(xx,yy,'FaceColor',repmat(1-i/numFits,1,3));
    plot(Fits{i},'w');
end
legend('off');
% 
% for i = 1:numFits
%     plot(Fits{i},'w');
% end

% The Data:
% x = 0:0.001:2;
% xx = [x x(end:-1:1)];
% y5 = x*fittedmodel5.p1;
% y5_CIlo = x*10.5;
% y5_CIup = x*10.85;
% y6 = x*fittedmodel6.p1;
% y6_CIup = x*3.679;
% y6_CIlo = x*3.91;
% y7 = x*fittedmodel7.p1;
% y7_CIup = x*5.638;
% y7_CIlo = x*5.861;
% y9 = x*fittedmodel9.p1;
% y9_CIup = x*4.634;
% y9_CIlo = x*4.743;
% y12 = x*fittedmodel12.p1;
% y12_CIup = x*3.819;
% y12_CIlo = x*3.983;
% Fits = [y5' y6' y7' y9' y12'];
% FitsCI(:,:,1) = [y5_CIlo' y6_CIlo' y7_CIlo' y9_CIlo' y12_CIlo'];
% FitsCI(:,:,2) = [y5_CIup' y6_CIup' y7_CIup' y9_CIup' y12_CIup'];