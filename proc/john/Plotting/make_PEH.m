function [H,bin_data]=make_PEH(bdf, event_times, window, unit, varargin)
    %make_PEH(bdf, event_times, window, unit, bin_size)
    %takes in a bdf, list of event times to build histogram around, a time
    %window, and the unit to build the histogram for. 
    %
    %the time window should be specified as a 2 element vector containing
    %the time in s pre- event and the time post-event to include in the
    %histogram. for instance [0.5, 1.5] would build histograms starting
    %500ms prior to event onset, through 1500ms post event onset.
    %
    %the unit should be a 2 element vector containing the channel number
    %and the unit on that channel. 
    %
    %can as a variable input take the bin size (in s) of the histogram and
    %a flag to make the function print information to the command window
    %during execution. If the bin size does not produce a whole number of
    %bins across the window range, the bin size will be adjusted to the
    %nearest numebr that produces an integer number of bins
    %
    %Returns a handle to a figure containing the perievent histogram.
    %because the hist function does not return a figure handle make_PEH
    %uses a bar plot to produce a histogram

    if ~isempty(varargin)
        bin_size=varargin{1};
        if length(varargin)>1
            verbose=varargin{2};
        end
    else
        verbose = 0;
        bin_size=.050;%s
    end
    num_bins=round((window(1)+window(2))/bin_size);
    bin_size=(window(1)+window(2))/num_bins;
    if verbose
        disp(strcat('Working on PEH for channel:',num2str(unit(1)),' unit #:',num2str(unit(2))))
        disp(strcat('Histogram will be computed starting ', num2str(window(1)),'ms prior to event onset, through ',num2str(window(2)),'ms after event onset'))
        disp(strcat('the histogram will have ',num2str(num_bins),' bins of ',num2str(bin_size),'ms length'))
        disp(strcat('There are ',num2str(length(event_times)),' events in this histogram'))
   end
    
    %check data types
    if length(event_times)<10
        warning('make_PEH:LIMITEDNUMBEROFEVENTS','There are less than 10 events specified for this histogram:')
    end
    if length(window)~=2
        error('make_PEH:INVALIDWINDOWSPECIFICATION','The time window passed in to make_PEH is not a 2 element vector')
    end
    if length(window)~=2
        error('make_PEH:INVALIDUNITSPECIFICATION','The unit passed in to make_PEH is not a 2 element vector')
    end
    
    
    timestamps = get_unit( bdf, unit(1), unit(2) );
    h_list=[];
    for i=1:length(event_times)
        temp=timestamps(timestamps>(event_times(i)-window(1)) & timestamps<(event_times(i)+window(2)));
        h_list=[h_list;temp-event_times(i)];
    end
    if verbose
        disp(strcat('Found: ',num2str(length(h_list)), ' spikes around the events. Computing histogram'))
    end
    
    bin_data=hist(h_list,num_bins);
    timepoints=[-window(1):bin_size:window(2)-bin_size]+(bin_size/2);
    H=figure;
    bar(timepoints,bin_data,1);
    %H is a handle to the bar-series object, not the plot, we need to get
    %the parent object handle
    bin_data=[bin_data;timepoints];
end