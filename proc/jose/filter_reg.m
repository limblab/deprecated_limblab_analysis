function H=filter_reg(X,Y,numlags,varargin)

X= detrend(X, 'constant'); Y=detrend(Y, 'constant');
Xd=DuplicateAndShift(X,numlags);

[nr nc] = size(Xd);
aux = Xd - [zeros(1,nc);Xd(1:end-1,:)];

if nargin > 3
    lambda = varargin{1};
    Q = lambda*(aux'*aux); 
    reg = 1;
else
    reg = 0;
end

if reg
    H = (Xd'*Xd+Q)\(Xd'*Y);
else
    H = (Xd'*Xd)\(Xd'*Y);    
end

