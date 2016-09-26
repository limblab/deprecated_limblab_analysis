function AffineT = createAffine(TDFxup,TDFxdwn,TDFyup,TDFydwn,TDFzup,TDFzdwn)
% Creates an affine transformation matrix that converts the given
% accelerations from the input TDF into properly scaled and rotated values.

%% first check the TDFs
if ~isstruct(TDFxup) || TDFxup.valTDF ~= 1
    error('Might wanna double check %s',inputname(1))
end

if ~isstruct(TDFxdwn) || TDFxdwn.valTDF ~= 1
    error('Might wanna double check %s',inputname(2))
end

if ~isstruct(TDFyup) || TDFyup.valTDF ~= 1
    error('Might wanna double check %s',inputname(3))
end

if ~isstruct(TDFydwn) || TDFydwn.valTDF ~= 1
    error('Might wanna double check %s',inputname(4))
end

if ~isstruct(TDFzup) || TDFzup.valTDF ~= 1
    error('Might wanna double check %s',inputname(5))
end

if ~isstruct(TDFxup) || TDFxup.valTDF ~= 1
    error('Might wanna double check %s',inputname(6))
end

%% Find means and stand devs fo' each
MV = struct('mean',[],'std',[]);
MV(1).mean = mean(TDFxup.accel,1);
MV(2).mean = mean(TDFxdwn.accel,1);
MV(3).mean = mean(TDFyup.accel,1);
MV(4).mean = mean(TDFydwn.accel,1);
MV(5).mean = mean(TDFzup.accel,1);
MV(6).mean = mean(TDFzdwn.accel,1);

MV(1).std = sqrt(var(TDFxup.accel,1));
MV(2).std = sqrt(var(TDFxdwn.accel,1));
MV(3).std = sqrt(var(TDFyup.accel,1));
MV(4).std = sqrt(var(TDFydwn.accel,1));
MV(5).std = sqrt(var(TDFzup.accel,1));
MV(6).std = sqrt(var(TDFzdwn.accel,1));

%% 









end