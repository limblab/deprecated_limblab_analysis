function [tuning gof peakness] = rand_walk_new(varargin)
% ONLY USED TO MAKE FIGURES BY BRIAN

% RAND_WALK( DATA, CHANNEL, UNIT ) - runs RW analytics
%   DATA    - a BDF structure
%   CHANNEL - the channel of the unit to run analytics on
%   UNIT    - the sort code of the unit to run analytics on
%
% RAND_WALK( DATA )
%   Does as above but for each unit in the BDF structure
%
% OUT = RAND_WALK( DATA ) - returns a matrix with a row for each cell
%   containing the following:
%       Channel, Unit, MIPeak, MIVal, Baseline, PD, PDgain, SpeedGain
%
% [OUT, GOF] = RAND_WALK( DATA ) - GOF returns a list of N rows and three
%   columns with the three columns being sse of the cosine model, sse of a
%   constant, and sse of zero as a model of the tuning curve
%
% [OUT, GOF, PEAKNESS] = RAND_WALK( DATA ) - PEAKNESS returns a measure of
%   how strong the peak in MI is.  Specifically it is the ratio of the
%   variance of the LP filtered MI curve to the variance of the HP filtered
%   MI curve.  A peakness > 5 indicates a "good cell".

% $Id: rand_walk_new.m 56 2009-03-06 18:21:55Z brian $

if nargin == 1
    run_all_units(varargin{1}, 1);
    return;
elseif nargin == 3
    data = varargin{1};
    channel = varargin{2};
    unit = varargin{3};
else
    error('invalid number of arguments');
end

s = get_unit(data, channel, unit);

%end_mi = floor(s(end));

b = train2bins(s, .001); % 1ms bins
b = b(1000:end); % drop points before begin mi
%v = [interp1(data.pos(1:end-1,1),dx,1:.001:end_mi)'
%interp1(data.pos(1:end-1,1),dy,1:.001:end_mi)'];
v = data.vel(:,2:3);

if (length(b) > length(v))
    b = b(1:size(v));
else
    v = v(1:length(b),:);
end

d = tmi(b, v, -1000:10:1000);

t = -1000:10:1000;
t = t.*0.001;
figure;
subplot(2,1,1),plot(t,d.*1000);
xlabel('Delay (s)');
ylabel('Mutual Information (Arbitrary Units)');
axis square;

% MI peak analysis
[peak peak_width good_cell peakness peak_height] = peak_analysis(d);

% recalculate spike train adjusting for offset
b = train2bins(s - peak, .001); % 1ms bins
b = b(1000:end); % drop points before begin mi
%v = [interp1(data.pos(1:end-1,1),dx,1:.001:end_mi)' interp1(data.pos(1:end-1,1),dy,1:.001:end_mi)'];
v = data.vel(:,2:3);

baseline = 1000 * sum(b) / length(b);

if (length(b) > length(v))
    b = b(1:size(v));
else
    v = v(1:length(b),:);
end

% spike scatter plot
%subplot(2,2,2),plot(dx(b==1), dy(b==1), 'k.');
%subplot(2,2,2),plot(data.vel(b==1,2), data.vel(b==1,3), 'k.')
%xlabel('X velocity (cm/s)');
%ylabel('Y velocity (cm/s)');

steps = 64;
cors = zeros(steps,3);
theta = 0:pi/(steps/2):pi*(steps-1)/(steps/2);
for i = 1:steps    
    mdl = bayes_regression(theta(i));
    conf = confint(mdl);
    cors(i,:) = [mdl.m conf(1,2) conf(2,2)];    
end

tuning = cors(:,1);
%subplot(1,4,3),shadedplot([theta 2*pi], [cors(:,2)' cors(1,2)], [cors(:,3)' cors(1,3)],[.7 .7 .7],[0 0 0]);
hold on;
%subplot(1,4,3),plot(theta, tuning, 'kx');

g = fittype('a*cos(x-b)+c', 'indep', 'x');
f = fitoptions('method', 'NonlinearLeastSquares', ...
    'StartPoint',[1 pi 0], ...
    'Lower', [0 0 -1000], ...
    'Upper', [1000 2*pi 1000]);
[curve, fgof] = fit(theta', tuning, g, f);
gof = [fgof.sse sum((tuning' - mean(tuning)).^2) sum(tuning.^2)];

subplot(2,1,2),plot(theta, curve(theta), 'k--');
subplot(2,1,2),plot_scale = axis;
axis([0 2*pi plot_scale(3) plot_scale(4)]);
ylabel('speed sensitivity (sp/cm)');
xlabel('direction');
set(gca,'XTick',0:pi/2:2*pi);
set(gca,'XTickLabel',{'0','pi/2','pi','3pi/2','2pi'})
axis square;

% get bayes plot for best direction
peak_th = find(cors(:,1) == max(cors(:,1)), 1);
[mdl, X, N, N2, P] = bayes_regression(theta(peak_th));
%[mdl, X, N, N2, P] = bayes_regression(3.14);
subplot(2,1,2),plot(X, N, 'b-', X, P/160, 'ko', X, N2, 'r-', X, mdl(X)/160, 'k--');
xlabel('speed (cm/s)');
ylabel('Probability');
axis square;

suptitle(sprintf('%d - %d', channel, unit));

if good_cell == 1
    tuning = [channel, unit, peak, peak_height, baseline, curve.b, curve.a, curve.c];
else 
    tuning = [channel, unit, NaN, NaN, NaN, NaN, NaN, NaN];
end

%pref_dir = theta(peak_th);
%pref_dir_peak = cor;

%suptitle(sprintf('%d-%d',channel,unit));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sub functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [peak, width, good_peak, peakness, peak_height] = peak_analysis(d)
    sd = smooth(d, 21)';
    dd = d - sd;
    if var(sd) > var(dd)*5
        good_peak = 1;
        peak_start = find(sd > mean(sd), 1, 'first');
        peak_end = find(sd > mean(sd), 1, 'last');
        width = peak_end - peak_start;
    else 
        good_peak = 0;
        width = 0;
    end
    peak = t(sd==max(sd));
    peakness = var(sd) / var(dd);
    peak_height = max(sd);
end

function [mdl, X, N, N2, P] = bayes_regression(th)
    v1 = cos(-th)*v(:,1) - sin(-th)*v(:,2);
    
    [N,X] = hist(v1, -30:2:30);
    [N2,X] = hist(v1(b==1),X);

    P = N2./N;
    N = N./sum(N);
    N2 = N2./sum(N2);
    
    P = P(2:length(P)-1);
    N = N(2:length(N)-1);
    N2 = N2(2:length(N2)-1);
    X = X(2:length(X)-1);
    
    myline = fittype('m*x+b');
    f = fitoptions('method', 'NonlinearLeastSquares', 'StartPoint', [1 0] );
    P = P ./ 0.001;
    mdl = fit(X(15:28)',P(15:28)', myline, f);
end % function bayes_regression(th)

function run_all_units(data, verbose)
    limit = -1;
    
    if verbose
        h = waitbar(0, 'Starting');
    end
    
    list = unit_list(data);
    
    tmp_tuning = [];
    tmp_gof = [];
    tmp_peakness = [];
    tic
    for j = 1:size(list,1);
        [res res_g res_p] = rand_walk_new(data, list(j,1), list(j,2));
        tmp_tuning = [tmp_tuning; res];         %#ok<AGROW>
        tmp_gof = [tmp_gof; res_g];             %#ok<AGROW>
        tmp_peakness = [tmp_peakness; res_p];   %#ok<AGROW>
        
        % write figure to ps
        set(gcf, 'PaperPosition', [1.25 2.5 6 6]);
        print('-r600', '-dpsc2', sprintf('tmp/fig%d', j));
        close(gcf);
        
        % status bar
        if verbose
            str = sprintf('Unit %d of %d', j, size(list,1));
            waitbar(j / size(list,1), h, str);
        end
        
        % limit (set limit above to -1 for unlimited)
        limit = limit - 1;
        if limit == 0
            break;
        end
        
        toc
    end

    tuning = tmp_tuning;
    gof = tmp_gof;
    peakness = tmp_peakness;
end % function run_all_units(data)

end % global close


