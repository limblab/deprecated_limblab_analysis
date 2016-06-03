function H=filter_reg(X,Y,numlags,varargin)

X= detrend(X, 'constant'); Y=detrend(Y, 'constant');
X=DuplicateAndShift(X,numlags);

[nr nc] = size(X);
aux = X - [zeros(1,nc);X(1:end-1,:)];

if nargin > 3
    lambda = varargin{1};
    Q = lambda*(aux'*aux); 
    reg = 1;
else
    reg = 0;
end
clear aux;

if reg
    H = (X'*X+Q)\(X'*Y);
else
    H = (X'*X)\(X'*Y);    
end

