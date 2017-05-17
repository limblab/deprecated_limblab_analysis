function D1 = iocat(dim,D1,D2)
% Concatenates idarx models along input (2) or output (1) dimension.

%  Copyright 2010-2012 The MathWorks, Inc.

D2 = idarx(D2); CovNew = [];
if dim==2
   % horzcat
   A = D1.A; Aj = D2.A;
   if isequal(A,Aj)
      Cov1 = D1.Covariance; Cov2 = D2.Covariance;
      if ~isempty(Cov1) && ~isempty(Cov2) && size(A,3)==1
         % If A is nontrivial, its covariance can't (in general) be merged
         n1 = numel(getp(D1));
         par1 = 1:n1;
         DCov1 = setp(D1,par1);
         
         n2 = numel(getp(D2));
         par2 = n1+(1:n2);
         DCov2 = setp(D2,par2);
         
         DCov1.B = local_horzcat_B(DCov1.B, DCov2.B);
         I = getp(DCov1);
         CovNew = permute(blkdiag(Cov1,Cov2),I);
      end
      D1.B = local_horzcat_B(D1.B, D2.B);
   else
      ctrlMsgUtils.warning('Ident:combination:idarxHorzcat1')
      D1 = iocat(2, idss(D1), idss(D2));
   end
else
   % vertcat
   Cov1 = D1.Covariance; Cov2 = D2.Covariance;
   if ~isempty(Cov1) && ~isempty(Cov2)
      n1 = numel(getp(D1));
      DCov1 = setp(D1,1:n1);
      DCov2 = setp(D2,n1+(1:numel(getp(D2))));
      DCov1.Covariance = []; DCov2.Covariance = [];
      [DCov1.A, DCov1.B] = local_vertcat_AB(DCov1.A, DCov1.B, DCov2.A, DCov2.B);
      CovNew = permute(blkdiag(Cov1,Cov2),getp(DCov1));
   end
   [D1.A, D1.B] = local_vertcat_AB(D1.A, D1.B, D2.A, D2.B);
end

D1 = iocat@idpack.ltidata(dim,D1,D2);
D1.Covariance = CovNew;

%--------------------------------------------------------------------------
function B = local_horzcat_B(B1, B2)
% horizontal concatenation
% Note: iocat(dim, object, object) does not dispatch to object.iocat
[ny, nu1, nb1] = size(B1);
[~, nu2, nb2] = size(B2);
B = zeros(ny,nu1+nu2,max(nb1,nb2));
B(:,1:nu1,1:nb1) = B1;
B(:,nu1+1:end,1:nb2) = B2;

%--------------------------------------------------------------------------
function [A,B] = local_vertcat_AB(A1, B1, A2, B2)
% Vertical concatenation of A, B matrices 

[ny1, ~, na1] = size(A1);
[ny2,~,na2] = size(A2);
A = zeros(ny1+ny2,ny1+ny2,max(na1,na2));
A(1:ny1,1:ny1,1:na1) = A1;
A(ny1+(1:ny2),ny1+(1:ny2),1:na2) = A2;

[~, nu, nb1] = size(B1);
[~, ~, nb2] = size(B2);
B = zeros(ny1+ny2,nu,max(nb1,nb2));
B(1:ny1,:,1:nb1) = B1;
B(ny1+1:end,:,1:nb2) = B2;
