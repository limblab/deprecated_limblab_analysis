function bdf = fake_bdf( orig_bdf )
%FAKE_BDF creates a bdf with fake, defined units
%
% Units:
%   1-1: X velocity cell | base 20 s^-1, gain 1 cm^-1
%   1-2: (same)   
%   1-3: (same)
%
%   2-1: Y velocity | base 20, gain 1
%   2-2: Y velocity | base 20, gain 2
%   2-3: Y velocity | base 40, gain 2
%
%   3-1: X velocity (speed term, increase only) | base 20, v-gain 2, s-gain 1
%   4-1: X vel/pos/speed | base 20, v-gain 2, s-gain 1, p-gain 1
%   5-1: X velocity/position | base 20, v-gain 2, p-gain 1
%   5-2: X velocity / Y position | base 20, v-gain 2, p-gain 1
%
%   6-1: X velocity (20|1) 30ms lead
%   6-2: X velocity (20|1) zero delay
%   6-3: X velocity (20|1) 30ms delay
%   6-4: X velocity (20|1) 100ms delay
%   6-5: X velocity (20|1) 200ms delay
%
%   7-1: X velocity (20|1) 100ms delay / instant
%   7-2: X velocity (20|1) 100ms delay / 50ms smooth
%   7-3: X velocity (20|1) 100ms delay / 100ms smooth
%   7-4: X velocity (20|1) 100ms delay / 200ms smooth
%   7-5: X velocity (20|1) 100ms delay / 500ms smooth

% $Id$

bdf = orig_bdf;

% Setup meta information and clear units
bdf.meta.filename = [bdf.meta.filename ' *** FAKE SPIKES ***'];
bdf.meta.bdf_info = '$Id$';

bdf.units = struct('id', {}, 'ts', {});

% Setup params to create fake units (non-delayed)
unit_ids = [1 1; 1 2; 1 3; 2 1; 2 2; 2 3; 3 1; 4 1; 5 1; 5 2];
unit_params = [...
%   m   Vx  Vy  X   Y   S
    20  1   0   0   0   0;... 1-1
    20  1   0   0   0   0;... 1-2
    20  1   0   0   0   0;... 1-3
    20  0   1   0   0   0;... 2-1
    20  0   2   0   0   0;... 2-2
    40  0   2   0   0   0;... 2-3
    20  2   0   0   0   1;... 3-1
    20  2   0   1   0   1;... 4-1
    20  2   0   1   0   0;... 5-1
    20  2   0   0   1   0;... 5-2
    ];

kin = [ones(size(bdf.vel,1),1) bdf.vel(:,[2 3]) bdf.pos(:,[2 3]) ...
    sqrt(bdf.vel(:,2).^2 + bdf.vel(:,3).^2)];

% find instantaneous firing rates for units
lambda = unit_params * kin';
lambda(lambda < 0) = 0;
lambda = lambda / 1000;

s = lambda > rand(size(lambda));

for unit = 1:length(unit_ids)
    ts = bdf.vel( s(unit,:)>0 , 1);
    bdf.units(unit) = struct('id', unit_ids(unit,:), 'ts', ts);
end

