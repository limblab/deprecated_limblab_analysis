% I don't know what to call this yet

global my_ep;
global base_angles;
global offset_angles;
global pelvic_points femoral_points tibial_points foot_points;
global base_lengths;
global segments;
global muscles;

% define pelvic points in the following order:
%
%   Hip rotation center (1)
%   Biceps femoris origin (2)
%   Iliopsoas origin (3)
%   Rectus femoris origin (4)
pelvic_points = [-3.95 -1.01; -6.84 0.16; 2.03 -1.80; -3.48 -0.65]'; % rotate original points so that coordinate frame matches global coordinate frame


% define femoral points (in femoral reference frame):
%
%   Hip Rotation center (5)
%   Knee Flexion (6)
%   Biceps femoris anterioris via point (7)
%   Medial Gastrocnemius origin (8)
%   VL action point (9)
%   Iliopsoas insertion (10)
%   Rectus femoris via point (11)
femoral_points = [.15 .14; 9.91 -.05; 9.28 .37; 9.15 0.06; 9.78 1.3; 0.81 -0.02; 9.98 1.50]';

% define tibial points:
%
%   Knee (12)
%   Ankle (13)
%   BFP action point (14)
%   Soleus origin (15)
%   Quadriceps action point (16)
%   Tibialis anterior action point (17)
tibial_points = [-1.5 0; 10.67 -.14; 2.55 .17; .78 -.41; .13 1.01; 8.96 0.67]';

% define foot points:
%
%   Ankle (18)
%   lMTP (19)
%   Medial Gastrocnemius action point (20)
%   Soleus insertion (21)
%   Tibialis anterior insertion (22)
foot_points = [3.57 3.88; 8.03 0; -.17 0.22; .02 .17; 3.65 0.12]';

master_points = [pelvic_points femoral_points tibial_points foot_points];

segments = [5 6; 12 13; 18 19];

% muscle order: BFA IP RF1 RF2 BFP VL MG SOL TA
% RF muscles will be consoldated in get_lengths.m
muscles = [2 7; 3 10; 4 11; 11 16; 2 14; 9 16; 8 20; 15 21; 17 22];

base_angles = [pi/4 -pi/4 pi/4];

angles = base_angles;

% calculate current angle offsets in model
offset_angles = zeros(1,3);
for i = 1:3
    seg_choice = segments(i,:);
    seg_angle = atan2(master_points(2,seg_choice(2)) - master_points(2,seg_choice(1)), master_points(1,seg_choice(2)) - master_points(1,seg_choice(1)));
    offset_angles(i) = seg_angle;
end

% get base lengths
get_mp;
get_lengths;
base_lengths = lengths;