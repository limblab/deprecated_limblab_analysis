if ~exist('bdf','var')
%     addpath('C:\Documents and Settings\limblab\Desktop\s1_analysis\')
    cd('C:\Documents and Settings\limblab\Desktop\s1_analysis\')
    load_paths
    cd('C:\Documents and Settings\limblab\Desktop\s1_analysis\proc\ricardo')

    dataFile = 'T:\Miller\TestData\bump_stim_forces_test_004.plx';

    cd('C:\Documents and Settings\limblab\Desktop\s1_analysis\bdf')
    bdf = get_plexon_data(dataFile);
    cd('C:\Documents and Settings\limblab\Desktop\s1_analysis\proc\ricardo')
end


bump.time =  bdf.words(bdf.words(1:end-2,2)>=80,1);
bump.mag = bdf.words(bdf.words(1:end-2,2)>=80,2)-80;
bump_count = 0;
no_bump_count = 0;
for i = 1:length(bdf.words)-2
    if bdf.words(i,2)>=80
        bump_count = bump_count+1;
        bump.trial_start(bump_count) = bdf.words(i-1,1);
        bump.trial_end(bump_count) = bdf.words(i+1,1);
        bump.trial_start_index(bump_count) = find(bdf.pos(:,1) > bump.trial_start(bump_count)-.002 &...
                bdf.pos(:,1) < bump.trial_start(bump_count)+.002,1);
        bump.trial_end_index(bump_count) = find(bdf.pos(:,1) > bump.trial_end(bump_count)-.002 &...
                bdf.pos(:,1) < bump.trial_end(bump_count)+.002,1); 
        if bdf.words(i+1,2)==32
            bump.succ(bump_count) = 1;
        else
            bump.succ(bump_count) = 0;
        end
    end
    if (bdf.words(i,2)==21 || bdf.words(i,2)==20) && bdf.words(i+1,2)<80
        no_bump_count = no_bump_count + 1;
        no_bump.trial_start(no_bump_count) = bdf.words(i-1,1);
        no_bump.trial_end(no_bump_count) = bdf.words(i+1,1);
        if bdf.words(i+1,2)==48
            no_bump.succ(no_bump_count) = 1;
        else
            no_bump.succ(no_bump_count) = 0;
        end
    end
end

for i = 1:length(bump.time)
    bump.force{i} = bdf.force(bump.trial_start_index(i):bump.trial_end_index(i),:);
    bump.pos{i} = bdf.pos(bump.trial_start_index(i):bump.trial_end_index(i),:);
end

for i = 1:length(bump.time)
    subplot(4,4,i)
    plot(bump.pos{i}(:,2),bump.pos{i}(:,3))
    xlim([-40 30])
    ylim([-70 0])
    hold on
    pause(.2)
end


