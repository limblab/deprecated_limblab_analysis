function g = bc_psychometric_curve(bdf)

    use_ml_fit = 1;

    tt = bc_trial_table(bdf);
    tt = tt(tt(:,7) ~= 65,:); % exclude aborts

    %lr = (tt(:,7)==double('R') & tt(:,2)==1) | (tt(:,2)==0 & tt(:,7)==double('F'));
    lr = tt(:,8);
    
    dirs = sort(unique(tt(:,3)));
    %dirs = dirs(dirs<=180); % TODO: Make this work for the other direction also
    %lr(dirs>=180) = ~lr(dirs>=180);
    
    ps = zeros(size(dirs));
    ns = zeros(size(dirs));
    xs = zeros(size(dirs));

    for i = 1:length(dirs)
        f = find(tt(:,3)==dirs(i));
        xs(i) = sum(lr(f));
        ps(i) = sum(lr(f)) / length(f);
        ns(i) = length(f);
    end

    % s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [.5 .5 .1 90], 'Lower', [0 0 0 0], 'Upper', [1 1 10 180]);
    % f = fittype('a+b*(erf(c*(x-d)))','options',s);
    % g = fit(tt(:,3), lr, f);

    dl = dirs(dirs<=180);
    dh = dirs(dirs>=180);
    dh = 360-dh;
    pl = ps(dirs<=180);
    ph = 1-ps(dirs>=180);

    x = xs;
    dd = 0:.01:180;
    if use_ml_fit
        optifun = @(data) nllik(dl,x(dirs<=180),ns(dirs<=180),data);
        g = fminsearch(optifun, [.45 .4 .05 90]);

        a = g(1); b = g(2); c = g(3); d = g(4);
        f = a + b*erf(c*(dd-d));   
    else
        s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [.5 .5 .1 90], 'Lower', [0 0 0 0], 'Upper', [1 1 10 180]);
        f = fittype('a+b*(erf(c*(x-d)))','options',s);
        g = fit(tt(:,3), lr, f);
        
        f = g(dd);
    end
            
    % subplot(2,1,1),plot(dirs,ps,'ko')
    subplot(2,1,1),plot(dl,pl,'ko')
    hold on;
    plot(dh,ph,'kx')
    plot(dd, f, 'r-');

    subplot(2,1,2),plot(dirs,ns,'ko')

    function nl = nllik(dirs, x, n, th)
        a = th(1); b = th(2); c = th(3); d = th(4);
        f = a + b*erf(c*(dirs-d));   
        %f = max(min(f,1),0);       
        nl = -sum( log(binopdf(x,n,f)) );
    end

end