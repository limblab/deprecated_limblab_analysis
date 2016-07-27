function AffineT = createAffine(TDFxup,TDFxdwn,TDFyup,TDFydwn,TDFzup,TDFzdwn)
% Creates an affine transformation matrix that converts the given
% accelerations from the input TDF into properly scaled and rotated values.

%% first check the TDFs
if ~isstruct(TDFxup) || TDFxup.valTDF ~= 1
    error('Might wanna double check TDFxup')
end

if ~isstruct(TDFxdwn) || TDFxdwn.valTDF ~= 1
    error('Might wanna double check TDFxup')
end

if ~isstruct(TDFyup) || TDFyup.valTDF ~= 1
    error('Might wanna double check TDFxup')
end

if ~isstruct(TDFydwn) || TDFydwn.valTDF ~= 1
    error('Might wanna double check TDFxup')
end

if ~isstruct(TDFzup) || TDFzup.valTDF ~= 1
    error('Might wanna double check %s',inputname(5))
end

if ~isstruct(TDFxup) || TDFxup.valTDF ~= 1
    error('Might wanna double check TDFxup')
end

%% Find means and 
