function error = CORerror(X)

global XYZDATA

C = X(1:3);
% r1 = X(4);
% r2 = X(5);
% r3 = X(6);
% r4 = X(7);

error = 0;

[N,M] = size(XYZDATA);
M = M/3;

for i = 1:N

   for j = 1:M
       index = 3*j-2;
       error = error + (norm(XYZDATA(i,index:index+2)' - C) - X(j+3))^2;
   end

end

% %-------------------------------------------------------------------------
%
% function error = CORerror(X)
%
% global R1 R2 R3 N
%
% C = X(1:3);
% r1 = X(4);
% r2 = X(5);
% r3 = X(6);
%
% error = 0;
%
% for i = 1:N
%
%     error = error + (norm(R1(i,:)' - C) - r1)^2;
%     error = error + (norm(R2(i,:)' - C) - r2)^2;
%     error = error + (norm(R3(i,:)' - C) - r3)^2;
%
% end
