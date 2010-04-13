function H = MIMOCE1(X, Y, numlags)

%    USAGE:   H=filMIMOCE1(X,Y,numlags,numsides,fs);
%
%
%    X        : Columnwise inputs  [x1 x2 ...] to the unknown system
%    Y        : Columnwise outputs [y1 y2 ...] to the unknown system
%    numlags  : the number of lags to calculate for all linear filters
%
%
% The returned filter matrix is organized in columns as:
%     H=[h11 h21 h31 ....;
%        h12 h22 h32 ....;
%        h13 h23 h33 ...;
%        ... ... ... ...]
%  Which represents the system:
%  y1=h11*x1 + h12*x2 + h13*x3 + ...     
%  y2=h21*x1 + h22*x2 + h33*x3 + ...     
%  y3=h31*x1 + h32*x2 + h33*x3 + ...

  [numpts,Nin]= size(X);
%   %add low gaussian noise to make data continuous
%    X = abs(X + 0.1*randn(size(X)));
  
%Duplicate and shift firing rate to account for time history; each time lag
%is considered as a different input.
%e.g. 10 neurons with 5 time lag = 50 inputs with no time lag
  X = DuplicateAndShift(X,numlags);

  H = X\Y;
  
end