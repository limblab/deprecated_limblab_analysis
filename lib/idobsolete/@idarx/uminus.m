function sys = uminus(sys)
%UMINUS  Unary minus for IDARX models.
%
%   MMOD = UMINUS(MOD) is invoked by MMOD = -MOD.
%
%   See also MINUS, PLUS.

 
%       Copyright 1986-2001 The MathWorks, Inc.

[a,b] = arxdata(sys);
sys = pvset(sys,'B',-b);
% REVISIT Covariance matrix

