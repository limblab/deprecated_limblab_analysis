% Stèphan Potgieter

function tt = sp_trial_table(bdf)
% own trial table

%%
% BC_TRIAL_TABLE - returns a table containing the key timestamps for all of
%                  the 2 bump choice trials in BDF
%
% Each row of the table coresponds to a single trial.  Columns are as
% follows:
%    1: Start time
%    2: Staircase used
%    3: Bump direction
%    4: Bump time
%    5: Time of go queue
%    6: End trial time
%    7: Trial result            -- R, F, or A
%    8: Direction moved         -- 1 for primary, 2 for secondary
%%

words = bdf.words; % gets a list of the words
db_times = cell2mat( bdf.databursts(:,1) ); % gets a list of the times at which a databurst took place


word_go = hex2dec('31'); % the go cue in words.h is defined as 0x31 -> hexadecimal number 31. hex2dec('31') = 49




