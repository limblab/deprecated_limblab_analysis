% preload bdf and trial table;

% Arthur_S1_018.mat
% mini_bumps_005-6.mat
% tiki_rw_006.mat
% Tiki_S1_b_005.mat
% Pedro_S1_011

% Clear except bdf and tt
vars = whos;
for i = 1:length(vars)
    if (~strcmp(vars(i).name,'bdf') && ~strcmp(vars(i).name,'tt'))
        clear(vars(i).name);
    end
end
clear i vars

kernel_sigma = .05;
t = -.5:0.005:1;
zero = find(t==0);
ms100 = find(t>.1,1);
ms50 = find(t>.05,1);
nms100 = find(t>-.1,1);
ms250 = find(t>.25,1);

%tt = co_trial_table(bdf);
ul = unit_list(bdf);

nTargets = max(tt(:,5)) + 1;
bumptrials = tt( tt(:,3) == double('H'), : );
table = cell(1,nTargets);

ps = cell(length(ul),nTargets);

for unitNumber = 1:length(ul)
    chan = ul(unitNumber, 1);
    unit = ul(unitNumber, 2);
    
    for dir = 1:nTargets
        onsets = bumptrials(bumptrials(:,2)==dir-1,4);
        table{dir} = raster(get_unit(bdf, chan, unit), onsets, -.75, 1.25, -1);
        
        ps{unitNumber,dir} = zeros(length(table{dir}), length(t));
        for trial = 1:length(table{dir})
            for spike = table{dir}{trial}'
            	ps{unitNumber, dir}(trial,:) = ps{unitNumber, dir}(trial,:) + ...
                    exp( - (t-spike).^2 / (2*kernel_sigma.^2) )./sqrt(2*pi*kernel_sigma^2);        
            end
        end
    end
end

%%
baseline = zeros(1,length(ul));
for unitNumber = 1:length(ul)
    tmp = [];
    for dir = 1:nTargets
        tmp = [tmp; ps{unitNumber,dir}(:,1)];
    end
    baseline(unitNumber) = mean(tmp);
end

q = [];
for unitNumber = 1:length(ul)
    tmp = [];
    for dir = 1:nTargets
        tmp = [tmp; ps{unitNumber,dir}(:,116)-baseline(unitNumber)];
    end
    q = [q tmp];
end

% q = [];
% for unitNumber = 1:length(ul)
%     tmp = [];
%     for timeslice = 1:length(t)
%         for dir = 1:nTargets
%             tmp = [tmp; ps{unitNumber,dir}(:,timeslice)];
%         end
%     end
%     q = [q tmp];
% end

lambda = factoran(q,3);

x = [];
y = [];
z = [];
for timeslice = 1:length(t)
    q = [];
    for unitNumber = 1:length(ul)
        tmp = [];
        for dir = 1:nTargets
            tmp = [tmp; ps{unitNumber,dir}(:,timeslice)-baseline(unitNumber)];
        end
        q = [q tmp];
    end

    proj = q * lambda;
    x = [x proj(:,1)];
    y = [y proj(:,2)];
    z = [z proj(:,3)];
    
    %plot(proj(:,1), proj(:,2), 'k.');
    %title(t(timeslice));
    %drawnow;
end

%%
colors = {'ko', 'bo', 'ro', 'go'};

figure; hold on;
for trial = 1:length(bumptrials)
    plot(x(trial,71:151), z(trial,71:151), '-', 'Color', [.5 .5 .5]);
    %plot3(x(trial,:), y(trial,:), z(trial,:), '-', 'Color', [.5 .5 .5]);
end

for bumpdir = 0:3
    f = sort(bumptrials(:,2)) == bumpdir;
    plot(x(f,116), z(f,116), colors{bumpdir+1});
    %plot3(x(f,113), y(f,113), z(f,113), colors{bumpdir+1});
end










