function arm_params = get_arm_params()

arm_params.plot = 0;
arm_params.clear_all = 0;
arm_params.num_training_sets = 2000;

%parameters
arm_params.g = 0;
% arm_params.m = [.35, .25];
arm_params.m = [.2, .1];
arm_params.l = [.2, .18];%segment lengths l1, l2
arm_params.m_ins = [.02 .02 .02 .02];
arm_params.lc = arm_params.l/2; %distance from center
arm_params.i = [arm_params.m(1)*arm_params.l(1)^2/3, arm_params.m(2)*arm_params.l(2)^2/3]; %moments of inertia i1, i2, need to validate coef's
arm_params.c = [.3,.3];
arm_params.Ksh = 3;
arm_params.Kl = .8;
arm_params.null_angles = [3*pi/4 pi/2];
% arm_params.Kl = 1;

arm_params.T = 0*[2;-.2];
arm_params.t = 0:.01:50;
arm_params.dt = diff(arm_params.t(1:2));
arm_params.F_max = [1000 1000 1000 1000];
arm_params.left_handed = 1;
arm_params.monkey_offset = [(-2*arm_params.left_handed+1)*.08 -sqrt(sum(arm_params.l.^2))]; 
