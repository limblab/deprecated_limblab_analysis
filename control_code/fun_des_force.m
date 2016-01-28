function [f] = fun_des_force(x,mF,mDir,fdes,xMin,c)

% Compute muscle forces from activations
muscF = zeros(length(x),1); 
for ii = 1:length(x)
    if x(ii) < xMin(ii)
        muscF(ii) = 0;
    else
        muscF(ii) = x(ii)*mF(ii);
    end
end

% Compute resultant force vector using all muscles and average directions
fhat = zeros(2,1);
fX = muscF.*cos(mDir'); fY = muscF.*sin(mDir');
fhat(1) = sum(fX);
fhat(2) = sum(fY);

% Cost function
R = c(1)*eye(length(x));
Q = eye(2)*c(2);
f = x'*R*x + (fhat-fdes)'*Q*(fhat-fdes);

% R = c(1)*eye(length(x),1);
% f = abs(x)'*R + (fhat-fdes)'*Q*(fhat-fdes);


% g1 = 2*x'*R;
% g2 = 2*(fhat-fdes)'*Q*[fX fY]';
% g = g1 + g2;

