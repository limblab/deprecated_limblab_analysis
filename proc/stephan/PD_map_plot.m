%% PD map plot. 
% This plots polar subplots showing the PDs and errorbounds in the location of
% their respective channels

% $Id: PD_map_plot.m Stèphan $


%% load paths and datafile (in bdf)

run('D:\My Documents\Uni\Master\Delft\stage\inhoud\s1_analysis\load_paths')

load('\\citadel.physiology.northwestern.edu\data\Mini_7H1\bdf\09-06-2012\Mini_Spike_LFPL_09062012006')
% get_plexon_data('filename') ; % if get_plexon_data works

%% calculate preferred directions

[pds, errs, moddepth] = glm_pds(out_struct); 

%% make plots
r = 0.01:0.01:1;

%% change this to match electrode channel orientations on the array
chan_list = randperm(96); % electrode mapping example: list of channel IDs sorted to their location. I assume channel ID's from unit_list match these. also that array is 8x12
num_elecs = 12; % number of electrodes in array, left to right.
%%

% chan_mat = vec2mat(chan_list,num_elecs); % matrix of channels
% chan_mat_helper = fliplr(chan_mat); % flips so that we can have elements in matrix corresponding to 2D array orientation (at least if the output from glm_pds is what I assume it is; PDs for each channel)
% for i=2:2:length(chan_mat(:,1)) % reorganizes matrix so that it is ordered the way I think it is, 1st row left-right, 2nd right-left etc.
%      chan_mat(i,:)=chan_mat_helper(i,:);
% end

u1 = unit_list(out_struct); % gets two columns back, first with channel
% numbers, second with unit sort code on that channel

figure
for iPD = 1:length(u1(:,1))
    angle = repmat(pds(iPD),1,length(r)); % vector size (1,length(r)) of elements equal to each preferred direction
    err_up = angle+repmat(errs(iPD),1,length(r)); 
    err_down = angle-repmat(errs(iPD),1,length(r));
    
    subplot(8,12,find(chan_list == u1(iPD,1),1,'first')) 
    h1 = polar(angle,r);
    hold on
    h2 = polar(err_up,r);
    h3 = polar(err_down,r);
    set(h1,'linewidth',3);
    [x1,y1]=pol2cart(angle,r); 
    [x2,y2]=pol2cart(err_up,r);
    [x3,y3]=pol2cart(err_down,r);
    
%     jbfill(x1,y1,y2,'b','b',1,0.5);
x_fill = [x2(end), x1(end), x3(end), 0];
y_fill = [y2(end), y1(end), y3(end), 0];

% fill(x_fill,y_fill,'r');
patch(x_fill,y_fill,'b','facealpha',0.3);
    title(['Elec ' num2str(u1(iPD,1))])
end
