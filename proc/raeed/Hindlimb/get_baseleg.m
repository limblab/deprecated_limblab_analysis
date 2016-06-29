function base_leg = get_baseleg
%set up struct with leg points to pass around

% define pelvic points in the following order:
%
%   Hip rotation center (1)
%   Biceps femoris origin (2)
%   Iliopsoas origin (3)
%   Rectus femoris origin (4)
a = 0;
base_leg.pelvic = [cos(a) -sin(a); sin(a) cos(a)]*([-3.95 -1.01; -6.84 0.16; 2.03 -1.80; -3.48 -0.65] - repmat([-3.95 -1.01],4,1))'; % rotate original points so that coordinate frame matches global coordinate frame
% base_leg.pelvic = [-3.95 -1.01; -6.84 0.16; 2.03 -1.80; -3.48 -0.65]';

% define femoral points (in femoral reference frame):
%
%   Hip Rotation center (5)
%   Knee Flexion (6)
%   Biceps femoris anterioris via point (7)
%   Medial Gastrocnemius origin (8)
%   VL action point (9)
%   Iliopsoas insertion (10)
%   Rectus femoris via point (11)
base_leg.femoral = [.15 .14; 9.91 -.05; 9.28 .37; 9.15 0.06; 9.78 1.3; 0.81 -0.02; 9.98 1.50]';

% define tibial points:
%
%   Knee (12)
%   Ankle (13)
%   BFP action point (14)
%   Soleus origin (15)
%   Quadriceps action point (16)
%   Tibialis anterior action point (17)
base_leg.tibial = [-1.5 0; 10.67 -.14; 2.55 .17; .78 -.41; .13 1.01; 8.96 0.67]';

% define foot points:
%
%   Ankle (18)
%   lMTP (19)
%   Medial Gastrocnemius action point (20)
%   Soleus insertion (21)
%   Tibialis anterior insertion (22)
base_leg.foot = [3.57 3.88; 8.03 0; -.17 0.22; .02 .17; 3.65 0.12]';

base_leg.master = [base_leg.pelvic base_leg.femoral base_leg.tibial base_leg.foot];

base_leg.segment_idx = [5 6; 12 13; 18 19];

% muscle order: BFA IP RF1 RF2 BFP VL MG SOL TA
% RF muscles will be consoldated in get_lengths.m
base_leg.muscle_idx = [2 7; 3 10; 4 11; 11 16; 2 14; 9 16; 8 20; 15 21; 17 22];
base_leg.num_muscles = 8;

% calculate current angle offsets in model
base_leg.offset_angles = zeros(1,3);
for i = 1:3
    seg_choice = base_leg.segment_idx(i,:);
    seg_angle = atan2(base_leg.master(2,seg_choice(2)) - base_leg.master(2,seg_choice(1)), base_leg.master(1,seg_choice(2)) - base_leg.master(1,seg_choice(1)));
    base_leg.offset_angles(i) = seg_angle;
end