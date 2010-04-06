
function output=array_movie(bdf)

%call bin_spikes --> returns  array and matrix
binned_data =bin_spikes(bdf);
   %array containing electrode numbers for each signal:
   spike_list = binned_data.spike_list;
   %matrix in which the columns are electrodes, rows are 50ms time bins:
   spike_rates = binned_data.spike_rates;

%thor_map--> returns cell array with subscripts of  position of each signal
subs=thor_map(spike_list);

%constants
num_bins =size(spike_rates,1);  %number of bins (several thousand)
fig1=figure(1);
winsize = get(fig1,'Position');
winsize(1:2) = [0 0];
frames_per_second = 20;
times_played = 1;

%initialize arrays
all_images =zeros(10,10,num_bins); %
%all_frames =

%create array activity image for each time bin
for i=1:num_bins
    %create 10x10 matrix of electrode activity
    all_images(:,:,i)=accumarray(subs,spike_rates(i,:),[10 10]);
    %create image
    imagesc(all_images(:,:,i))
    %store image as single movie frame
    all_frames(:,i)=getframe(fig1,winsize);  
end

%play movie
output=movie(all_frames,times_played,frames_per_second) 


