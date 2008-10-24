function f = bytes2float(varargin)
% BYTES2FLOAT - converts bytes to their floating point representation
%   F = BYTES2FLOAT( B ) Returns a list of N floating point number
%   represnted by the bytes B, which must have a length of N*4.  The bytes
%   in B should be arranged in little-endian format.
%
%   F = BYTES2FLOAT( B, ENDIAN ) Does the same for the specified byte
%   order.  ENDIAN must take one of the values 'big' or 'little'

% $Id$

b = varargin{1};
if nargin > 1
    e = varargin{2};
    if strcmp(e, 'big')
        littleendian = 0;
    elseif strcmp(e, 'little')
        littleendian = 1;
    else 
        error('Unrecognized byte order')
    end
else 
    littleendian = 1;
end

if mod(length(b), 4) ~= 0
    error('B must have a length that is an integer multiple of 4')
end

if any(b>256) || any(b<0)
    error('B must contain only integer values between 0 and 255')
end

b = floor(b);

grid = reshape(b,4,[])';
if littleendian == 0
    grid = [grid(:,4) grid(:,3) grid(:,2) grid(:,1)];
end

signs    = grid(:,4) >= 128; % from standard
signs    = -(signs*2 - 1);   % convert to +1 or -1
exponent = (grid(:,3) >= 128) + mod(grid(:,4),128)*2 - 127;
mantisa  = 2^16 * mod(grid(:,3), 128) + ...
           2^8  * grid(:,2) + grid(:,1);

mantisa = mantisa + 2^23 * ~(exponent == -127 & mantisa == 0);
mantisa = mantisa / 2^23;

f = signs .* 2.^exponent .* mantisa;

