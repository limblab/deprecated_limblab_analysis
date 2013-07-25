% I don't know what to call this yet

global my_ep;
global base_angles;
global pelvic_points femoral_points tibial_points foot_points;

% define pelvic points in the following order:
%
%   Hip rotation center (1)
%   Biceps femoris origin (2)
pelvic_points = [2.0789    4.9497; 3.5072    4.7235]; % from rotating line below
%pelvic_points = [3.95 1.01; 6.84 -.16]';


% define femoral points (in femoral reference frame):
%
%   Hip Rotation center (3)
%   Knee Flexion (4)
%   Biceps femoris anterioris via point (5)
%   Biceps femoris anterioris insertion (6)
%   Plantaris origin (7)
%   VL action point (8)
femoral_points = [.15 .14; 9.91 -.05; 9.28 .37; 10.52 -1.56; 9.05 .27; 9.78 1.3]';

% define tibial points:
%
%   Knee (9)
%   Ankle (10)
%   BFP via point (11)
%   BFP insertion (12)
%   Soleus origin (13)
%   FDL origin (14)
%   VL action point (15)
tibial_points = [-1.5 0; 10.67 -.14; 2.55 .17; 2.67 .89; .78 -.41; 10.8 -.24; .13 1.01]';

% define foot points:
%
%   Ankle (16)
%   lMTP (17)
%   Plantaris action point (18)
%   Soleus insertion (19)
%   FDL action point (20)
foot_points = [3.57 3.88; 8.03 0; -.11 -.24; .2 .17; 2.67 -.17]';

master_points = [pelvic_points femoral_points tibial_points foot_points];

segments = [3 4; 9 10; 16 17];

% muscle order: BFA BFP VL PT FDL
muscles = [2 5; 2 11; 8 15; 7 18; 14 20];

base_angles = [pi/4 -pi/4 pi/4];

angles = base_angles;



