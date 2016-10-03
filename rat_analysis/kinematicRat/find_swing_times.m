function swing_times = find_swing_times(steep_cutoff, time_interval, ankle_array)
% Calculates the beginning and end of every swing phase of the step cycles,
% returns a cell array that is n cells long, where n is the number of swing
% cycles found. Each cell is 1x2 vector containing the indices of beginning 
% and end of the swing cycle. Calculates areas where there is a large
% difference (greater than steep_cutoff) between time t and time
% t-time_interval.
% INPUTS: 
% steep_cutoff - the largest difference in values to allow
% time_interval - the number of values to step back 
% ankle_array - the vector of ankle joint angle values
% Maria Jantz, 06-20-2016
% 
% for i=1+time_interval:length(ankle_array)
%     newarr(i) = ankle_array(i)-ankle_array(i-time_interval);
% end
% 
% sorted = sort(newarr);
% indices = abs(sorted)<steep_cutoff;
% sorted(indices) = []; %remove all values from the array that are not sufficiently steep slopes
% sorted(isnan(sorted))=[]; %remove all NaN values from the array.
% possible_peaks = [];
% 
% for i=1:length(sorted)
%     possible_peaks(i) = find(newarr==sorted(i)); %get the index values for each region of steep slopes
% end
% %scatter(possible_peaks, sorted(1:length(possible_peaks))) %scatter plot
% sort_peaks = sort(possible_peaks); 
% %now group the possible peaks into ranges
% j=1;
% swing_times = {};
% for i=2:length(sort_peaks)
%     %break into chunks; if there is a large gap between values it must be
%     %the next step cycle
%     if sort_peaks(i)-sort_peaks(i-1)>35 || i==length(sort_peaks) 
%         if sort_peaks(i-1)-sort_peaks(j)<25 %if it's a very short slice, ignore it
%             j=i; 
%         else
%             k = int64((i-j)*.7 + j); %ending value index; adjusted a bit so it doesn't include stance
%             swing_times{end+1} = [sort_peaks(j) sort_peaks(k)];
%             j=i;
%         end
%     end
% end


%NEW VERSION (

end