function ts_table = parse_words(bdf)
%Output whatever word/timestamps we're interested in from the visual
%search task

%% Strategy:
%find all start_trials
%find successful trials


%%

%-initialize
%START_TRIAL = 27;
%CT_ON       = 48;
%OT_ON       = 64; %word codes of interest (in decimal, not hex)
 OT_MIN      = 63;
%OT_MAX      = 71;
%MVMNT_ONSET = 128;
REWARD      = 32;

words = bdf.words;
all_positions =  get_positions(bdf);

reward_times = words( find(words(:,2) == REWARD), 1);%START_TRIAL, 1 );
num_rewards = length(reward_times);

wins  = zeros(num_rewards, 6);
 t     = 1;
 start = 1;
%ct    = 2;
 ot    = 3;  %event column indices for 'wins' matrix
%onset = 4;
 drink = 5;
 targ  = 6;


for reward = 2:num_rewards
    
    curr_idx = find( words(:,t) == reward_times(reward) ); %index in the 'words' struct (Nx2 matrix) where the given reward occurs
    prev_idx = find( words(:,t) == reward_times(reward-1) );
    
    %if ( length(curr_idx) == 1 && length(prev_idx) == 1 )
        curr_trial = words(prev_idx+1:curr_idx,:); %takes only values of interest
        wins(reward, drink) = words(curr_idx, t);
        % OK, so we have the timestamp for a given reward, now we need to
        % fill in the preceding values.
        % So first: parse out events in 'curr_trial'

        %make sure there's only one trial in current sequence
        curr_start = find(curr_trial(:,2) == 27);
        if     ( length(curr_start) > 1 )

            %find start time directly preceding given reward
            curr_start = curr_start(end);
            wins(reward,start) = curr_trial(curr_start,t); %set trial start time
            %this is not robust, but it'll do for now (hopefully)
            for i = 1:3
                % fill in ct_on, ot_on, and mvmnt_onset times for given trial
                wins(reward,start+i) = curr_trial(curr_start+i, t);
                if (i == 2) %get target number
                    wins(reward,targ) = curr_trial(curr_start+i, 2) - OT_MIN;
                end
            end

        elseif ( length(curr_start) == 1 )

            wins(reward,start) = curr_trial(curr_start,t); %set trial start time
            %this is not robust, but it'll do for now (hopefully)
            for i = 1:3
                % fill in ct_on, ot_on, and mvmnt_onset times for given trial
                wins(reward,start+i) = curr_trial(curr_start+i, t);
                if (i == 2) %get target number
                    wins(reward,targ) = curr_trial(curr_start+i, 2) - OT_MIN;
                end
            end

        else
            %if no start time for some reason
            continue;
        end
    %else
    %    continue;
    %end
    

end

%get target number from 'ot_on' code
%[c,ia,ib]  = intersect(wins(:,ot),words(:,t));
%targ_codes = words(ib,2);
%size(targ_codes)
%size(wins)
%wins
%wins(:,targ) = targ_codes - OT_MIN;

ts_table = wins;









