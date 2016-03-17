%
% Function that does a checker plot for the STAs, taking as input a set of
% STA files collected with the funcion STIM_TRIG_AVG(). The checker
% plot represents metrics that are obtained CALCULATE_STA_METRICS()
%
%   function plot_cortical_map( varargin )
%
%       VARARGIN{1}     : the muscles that will be plotted (specified by
%                           channel numbers)
%       VARARGIN{2}     : the folder that contains the files that will be
%                           used for the plot. 
%       VARARGIN{3}     : the array map file
%
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       % ToDos:
%       - Disregard MPSFs when the P value (obtained following Poliakov &
%       Schiebert's method) is non-significant.
%       - Expand the code to look at MPSI
%


function plot_cortical_map( varargin )



% options
plot_MPSF_per_ch_yn     = 1;    % This should be a paramter!!!


if nargin == 1
   
    selected_muscles    = varargin{1};
elseif nargin == 2
    
    selected_muscles    = varargin{1};
    file_dir            = varargin{2};
elseif nargin == 3
    
    selected_muscles    = varargin{1};
    file_dir            = varargin{2};
    [arr_map,~]         = get_array_mapping(varargin{2});
else

    % If not specified, plot all the muscles
    selected_muscles    = 0;    % ToDo: see how to improve this
    
    % Array map for Jango; hardcoded
    [arr_map,~]         = get_array_mapping('/Users/juangallego/Documents/NeuroPlast/Data/Jango/ArrayMaps/Jango_RightM1_utahArrayMap.cmp');
    
    % The folder where the files that we want to use are
    file_dir            = '/Users/juangallego/Documents/NeuroPlast/Data/Jango/CorticalMaps/_selected_files/';
end


% go to the directory with the files and see what's in there
cd(file_dir);
corticalMapFiles        = dir;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create vector 'pos_array', which converts the electrode number to its
% position in the array 

for i = 1:max(max(arr_map))
   
    pos_array(i)       	= find(arr_map == i);
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pool the results: Load each file and calcualte the StTA metrics by
% calling 'CALCULATE_STA_METRICS'.

for i = 1:length(corticalMapFiles)
   
    
    if(length(corticalMapFiles(i).name) > 4)
        
        load(corticalMapFiles(i).name);


        % Ch nbr; for storing the data
        ch_nbr          = sta_params.stim_elecs;

        if sta_params.bank == 'B'

            ch_nbr      = ch_nbr + 32;
        elseif sta_params.bank == 'C'

            ch_nbr      = ch_nbr + 64;
        end
        
        % Calculate the metrics wihtout plotting the maps
        sta_metrics(ch_nbr)     = calculate_sta_metrics( emg, sta_params );
        
        % read other stuff such as nbr_stim per channel
        % ToDo
    end
end


% Create matrix 'STA_ARRAY', which contains the sta_metrics for each muscle
% of the recorded electrode and muscle that we want to plot


% What muscles to plot. == 0 means all
if selected_muscles == 0
   
    selected_muscles        = 1:emg.nbr_emgs;
    
    % If the monkey is Jango, and we recorded EDC2 and FCU, get rid of
    % them; the electrodes are broken
    if strncmp('Jango',sta_params.monkey,5) && ( find(strncmp('EMG_EDC2',emg.labels,8)) || find(strncmp('EMG_FCU',emg.labels,7)) )
        
        selected_muscles(strncmp('EMG_EDC2',emg.labels,8))          = [];
        selected_muscles(strncmp('EMG_FCU',emg.labels,7))           = [];
    end
end


% STA_ARRAY is created here. In this version it contains only the MPSF, but
% the same code could be reused for plotting other things...
for i = 1:length(sta_metrics)
    
    % get rid of chs 32, 64 and 96, for which we don't record data
    if mod(i,32) ~= 0
    
        sta_array(i,:)      = sta_metrics(i).MPSF(selected_muscles);
    end
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if specified, plot the mgnitude of MPSF per cortical electrode and muscle
% ToDo: improve this so the broken channels are removed (as they are in the
% next chunk of code)

if plot_MPSF_per_ch_yn
    
    for i = 1:numel(selected_muscles)
        
        temp_array_plot     = zeros(10,10);
        temp_array_plot(pos_array(1:length(sta_array)))     = sta_array(:,i);
        
        figure,
        imagesc(temp_array_plot),colormap('jet'),title([emg.labels{selected_muscles(i)}(5:end) ' - PSF'],'Fontsize',14),colorbar;
        xlabel('array row','Fontsize',12),ylabel('array column','Fontsize',12)
        
        % label the non-connected electrodes as 'n.c.'
        % Note: col and row are inverted when using text
        [pos_nc_elec_col, pos_nc_elec_row]                  = find(arr_map==0); 
        text(pos_nc_elec_row,pos_nc_elec_col,'n.c.','HorizontalAlignment','center','color','w','Fontsize',14)
        
    end
end




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Do a polar plot per channel that shows which muscles receive projections
% from each cortical site. The plot shows 1/0 information (yes/no)


% some things for the plot
muscle_colors                   = jet(numel(selected_muscles));
[~, elec_nbr_pos]               = sort(pos_array);  % this variable tells you where each electrode is


figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:10
    for j = 1:10
   
        % get rid of chs 32, 64 and 96, for which we don't record data
        curr_elec_nbr       = find(pos_array == (i+10*(j-1)),1);
        
        % if the electrode hasn't been mapped, remove it
        if curr_elec_nbr > length(sta_array)
            curr_elec_nbr   = [];
        end
        
        if ( mod(i,32) ~= 0 ) && ~isempty(curr_elec_nbr)    % ToDo: fix this to represent the non-connected positions
            
            fac_muscles             = find(sta_array(curr_elec_nbr,:));

            %h_sbp = subplot(10,10,i+10*(j-1));
            h_sbp = subplot(10,10,(i-1)*10+j);    % this little trick is to deal with how subplot names the subplots
            get(h_sbp, 'pos');
            set(h_sbp,'pos',[.09*(j-1), .9-.09*(i-1), .085, .085]); %.095
            
            % Plot facilitated muscles, or leave blank
            if numel(fac_muscles) > 0
                for ii = 1:numel(fac_muscles)

                    h_p = polar([0 2*pi/numel(selected_muscles)*(fac_muscles(ii)-1)],[0 1]);
                    set(h_p,'LineWidth',4);
                    set(h_p,'color',muscle_colors(fac_muscles(ii),:));
                    hold on;
                end
                hold off
            else
                h_p = polar([0 0],[0 0]);
            end
            
            delete(findall(ancestor(h_p,'figure'),'HandleVisibility','off','type','line','-or','type','text'));    % delete the grid and the ticks
        end
    end
end


% This figure is the legend for the previous one
figure
for i = 1:numel(selected_muscles)
    h_p = polar([0 2*pi/numel(selected_muscles)*(i-1)],[0 1]);
    set(h_p,'LineWidth',4);
    set(h_p,'color',muscle_colors(i,:));
    hold on
end
hold off
delete(findall(ancestor(h_p,'figure'),'HandleVisibility','off','type','line','-or','type','text'));    % delete the grid and the ticks
legend(emg.labels{setdiff(1:emg.nbr_emgs,pos_muscles_to_remove)})