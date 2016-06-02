function g = bc_psychometric_curve(tdf)

    use_ml_fit = 1;

    tt = tdf.tt( ( tdf.tt(:,tdf.tt_hdr.trial_result) ~= 1 ) ,  :); % exclude aborts
    tt=tdf.tt( ( tdf.tt(:,tdf.tt_hdr.stim_trial) == 1 ) ,  :);%exclude non stim trials

    %generate a vector containing a 1 if the reach was leftward along the
    %target axis, and zero if the reach was rightward
    %note: the following computation for the number of leftward reaches
    %assumes that the bump angle never exceeds 360 deg
    is_left_reach =( tt(:,tdf.tt_hdr.trial_result)==0 & 90 <= tt(:,tdf.tt_hdr.bump_angle) &  tt(:,tdf.tt_hdr.bump_angle)<= 270 |...
        tt(:,tdf.tt_hdr.trial_result)==2 & -90 <= tt(:,tdf.tt_hdr.bump_angle) & tt(:,tdf.tt_hdr.bump_angle) <= 90 |...
        tt(:,tdf.tt_hdr.trial_result)==2 & 270 <= tt(:,tdf.tt_hdr.bump_angle) & tt(:,tdf.tt_hdr.bump_angle) <= 360  );

    dirs = sort(unique(tt(:,tdf.tt_hdr.bump_angle)));
    
    proportion = zeros(size(dirs));
    number_reaches = zeros(size(dirs));
    num_reaches = zeros(size(dirs));

    for i = 1:length(dirs)
        reaches = find(tt(:,tdf.tt_hdr.bump_angle)==dirs(i));
        num_reaches(i) = sum(is_left_reach(reaches));
        proportion(i) = sum(is_left_reach(reaches)) / length(reaches);
        number_reaches(i) = length(reaches);
    end


    left_dirs = dirs(dirs<=180);
    right_dirs = dirs(dirs>=180);
%    right_dirs = 360-right_dirs;%remapps the angles so that the left and right bumps can plot along the same axis
    right_dirs = right_dirs-180;%remapps the angles so that the left and right bumps can plot along the same axis

proportion_left = proportion(dirs<=180);
    proportion_right = 1-proportion(dirs>=180);


    x = num_reaches;
    dd = 0:.01:180;
    if use_ml_fit
        optifun = @(data) nllik(left_dirs,x(dirs<=180),number_reaches(dirs<=180),data);
        g = fminsearch(optifun, [.45 .4 .05 90]);

        a = g(1); b = g(2); c = g(3); d = g(4);
        reach_fit = a + b*erf(c*(dd-d));   
    else
        s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [.5 .5 .1 90], 'Lower', [0 0 0 0], 'Upper', [1 1 10 180]);
        ft = fittype('a+b*(erf(c*(x-d)))','options',s);
        g = fit(tt(:,3), is_left_reach, ft);
        
        reach_fit = g(dd);
    end
            
    % subplot(2,1,1),plot(dirs,ps,'ko')
    subplot(2,1,1),plot(left_dirs,proportion_left,'ko')
    hold on;
    plot(right_dirs,proportion_right,'kx')
    plot(dd, reach_fit, 'r-');

    subplot(2,1,2),plot(dirs,number_reaches,'ko')

    function nl = nllik(dirs, x, n, th)
        a = th(1); b = th(2); c = th(3); d = th(4);
        y = a + b*erf(c*(dirs-d));   
        %f = max(min(f,1),0);       
        nl = -sum( log(binopdf(x,n,y)) );
    end

end