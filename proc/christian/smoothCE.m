function sm = smoothCE(X,varargin)

n = size(X,1);
sm = nan(size(X));

if nargin >1
    span = varargin{1};
    span = span-1+mod(span,2); % force it to be odd, -1 if even
    span = min(n,span);
else
    span = 5;
    span = min(n,span);
end

halfspan = span-ceil(span/2);

for i = 1:n
    L = max(1,i-halfspan);
    R = min(n,i+halfspan);
    sm(i,:) = mean(X(L:R,:));
end