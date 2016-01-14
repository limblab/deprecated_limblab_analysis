function y = medfilt1nan( x, s )
% standard median filter (copied from medfilt1.m)
n=length(x); r=floor(s/2); indr=(0:s-1)'; indc=1:n;
ind=indc(ones(1,s),1:n)+indr(:,ones(1,n));
x0=x(ones(r,1))*0; X=[x0'; x'; x0'];
X=reshape(X(ind),s,n); 

y=nanmedian(X,1);
end