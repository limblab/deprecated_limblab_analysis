function [opts]=getTask(cds,task,opts)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %getTask attempts to identify the 
    %attempt to identify task using the word codes
        if ~ isempty(cds.words)%exist('words','var')
            start_trial_words = cds.words.word( bitand(hex2dec('f0'),cds.words.word) == hex2dec('10'));
            if ~isempty(start_trial_words)
                start_trial_code = start_trial_words(1);
                if ((start_trial_code >= hex2dec('11') && start_trial_code <= hex2dec('15')) || ...
                        start_trial_code >= hex2dec('1a') && start_trial_code<=hex2dec('1F') || ...
                        start_trial_code == hex2dec('18') )
                        opts.robot=true;
                    if start_trial_code == hex2dec('17')
                        opts.task='WF';
                    elseif start_trial_code == hex2dec('11')
                        opts.task='CO';
                    elseif start_trial_code == hex2dec('12')
                        opts.task='RW';
                    elseif start_trial_code == hex2dec('19')
                        opts.task='ball_drop';
                    elseif start_trial_code == hex2dec('16')
                        opts.task='multi_gadget';
                    else
                        error('BDF:unkownTask','Unknown behavior task with start trial code 0x%X',start_trial_code);
                    end
                end
            end
        else
            warning('NEVNSD2cds:noWords','No WORDs are present');
        end
        if isfield(opts,'task') && ~isempty(task) && ~strcmp(opts.task,task)
            error('NEVNSD2cds:BadTask',['The start word codes in this file are not of a type consistent with the user specified task:',temptask] )
        end
        if isempty(task) 
            warning('getTask:NoTaskSet','cds.getTask was unable to identify the task of this data automatically. Please re-load the data and specify the task used so that trial data can be parsed correctly')
            if ~isfield(opts,'task')
                task=cds.meta.task;%set it back to whatever is in the cds (default would be 'Unknown')
            end
        end
end