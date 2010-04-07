function spike_activity = array_movie(bdf, monkey_name)


binned_data = bin_spikes(bdf); %call bin_spikes --> returns array of usable units and matrix of binned spike rates
spike_list  = binned_data.spike_list; %array containing electrode numbers for each signal
spike_rates = binned_data.spike_rates; %matrix in which the columns are channels, rows are 50ms time bins

%thor_map--> returns cell array with subscripts of  position of each signal
subs = array_activity_map(spike_list, monkey_name); %David's version
%subs = thor_map(spike_list); %Becca's version

%constants
num_bins          = size( spike_rates, 1 );  %number of bins (several thousand)
fig1              = figure(1);
%winsize           = get(fig1,'Position');
%winsize(1:2)      = [0 0];
frames_per_second = 20;  %based on 50ms/frame (real-time playback)
times_played      = 1;

%initialize arrays
all_images = zeros( 10, 10, num_bins );
all_frames = zeros( 1, num_bins );

%create array activity image for each time bin
for i = 1:num_bins
    
    all_images(:,:,i) = accumarray( subs, spike_rates(i,:), [10 10] ); %create 10x10 matrix of electrode activity
    imagesc( all_images(:,:,i) ) %create image    
    all_frames(i) = getframe( fig1);%, winsize ); %store image as single movie frame

end

%play movie
spike_activity = movie( all_frames, times_played, frames_per_second ); %#ok<NOPRT>
%disp( spike_activity )

