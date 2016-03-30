

function cropped_binned_data = call_crop_binned_data_wf( binned_data_array, word_i, word_f )


% get the column of the words
switch word_i
    case 'start'
        indx_i              = 1;
    case 'ot_on'
        indx_i              = 6;
    case 'go'
        indx_i              = 7;
    otherwise
        error([word_i ' not supported for this task']);
end

switch word_f
    case 'ot_on'
        indx_f              = 6;
    case 'go'
        indx_f              = 7;
    case 'end'
        indx_f              = 8;
    case 'R'
        indx_f              = 8; % code will then look at whether the monkey got a reward
    otherwise
        error([word_i ' not supported for this task']);
end


nbr_bdfs                    = length(binned_data_array);


for i = 1:nbr_bdfs

    % get trial table and store it in a N x 2 matrix with times for
    % cropping 
    trial_table             = binned_data_array(i).trialtable;
    cropping_times          = [trial_table(:,indx_i), trial_table(:,indx_f)];

    % if the end word is 'R' (reward), get rid of the trials without a reward
    if word_f == 'R'
        cropping_times(trial_table(:,9) ~= double('R'),:) = [];
    end

    % call cropping function
    cropped_binned_data(i)  = crop_binned_data( binned_data_array(i), cropping_times );

    
    clear trial_table cropping_times;
end