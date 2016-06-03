function outMat=safetyLog(logFnH,inMat)

% syntax outMat=safetyLog(logFnH,inMat);
%
%   INPUTS
% 
%           logFnH      - function handle.  should work for any of 
%                         matlab's defined mathematical log functions
%
%           inMat       - numerical input array
%
%   OUTPUTS
%   
%           outMat      - the output array.
%
% 
% safetyLog should calculate logarithms exactly as the passed-in function
% would, with the exception that it applies the convention log(0)=0.

inMat(inMat==0)=NaN;
outMat=feval(logFnH,inMat);
outMat(isnan(outMat))=0;