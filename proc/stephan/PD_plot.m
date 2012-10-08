function PD_plot(varargin)

% PD_PLOT = PD_plot(BDF,ARRAY_MAP_FILEPATH,INCLUDE_UNSORTED,INCLUDE_HISTOGRAMS)
%       generates PD plots. BDF is data in the bdf structure. ARRAY_MAP_FILEPATH
%       should be a string ; the filepath of the array mapping.
%       INCLUDE_UNSORTED allows the inclusion of unsorted units in the PD
%       calculation of different from 0. INCLUDE_HISTOGRAMS plots several
%       histograms if different from 0. 

% 


bdf = varargin{1};
cerebus_array_map_filepath = varargin{2}; 
if length(varargin)<3
    include_unsorted = 0;
else
    include_unsorted = varargin{3}; % so the third input parameter determines whether or not unsorted units are taken into account
end

% include_unsorted = 1 ; 
% cerebus_array_map_filepath = 'D:\My Documents\Uni\Master\Delft\stage\inhoud\data\Kramer implant array map\6251-0922.cmp';

%% get pds, standard errors and modulation depth
[pds, errs, moddepth] = glm_pds(bdf,include_unsorted); 

%% PD map plot. 
% This plots polar plots showing the PDs and errorbounds in the location of their respective channels

[chan_list,cer_list] = get_array_mapping(cerebus_array_map_filepath);
[r,c] = size(chan_list);

chan_list_up = chan_list(1:floor(r/2),:); % channel list for the upper-half plot
chan_list_low = chan_list((floor(r/2)+1):end,:);

[subplot_dim_up_r,subplot_dim_up_c]=size(chan_list_up); % subplot dimensions
[subplot_dim_low_r,subplot_dim_low_c]=size(chan_list_low); % subplot dimensions

CI = errs*1.96; % confidence bounds

u1 = unit_list(bdf,1); % gets two columns back, first with channel
% numbers, second with unit sort code on that channel

h_up = figure('name','PDs upper half of array');
h_low = figure('name','PDs lower half of array');

for iPD = 1:length(u1(:,1))
    r = 0.001:0.01:moddepth(iPD)/max(moddepth);
    angle = repmat(pds(iPD),1,length(r)); % vector size (1,length(r)) of elements equal to each preferred direction
    err_up = angle+repmat(CI(iPD),1,length(r)); % upper error bound
    err_down = angle-repmat(CI(iPD),1,length(r)); % lower error bound
    if max(max(chan_list_low' == u1(iPD,1)))
        figure(h_low);
        subplot(subplot_dim_low_r,subplot_dim_low_c,find(chan_list_low' == u1(iPD,1),1,'first')) % put the plot in the correct location relative to position in array ( [ 1 2 3;..
                                                                                                                               % 4 5 6 ]; )
        h1 = polar(angle,r);
        hold on
        h2 = polar(err_up,r);
        h3 = polar(err_down,r);
        set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
            '-or','String','150','-or','String','210','-or','String','240',...
            '-or','String','300','-or','String','330','-or','String','  0.2',...
            '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
            '-or','String','  0.1','-or','String','  1') ,'String', ' ');
        set(h1,'linewidth',2);
        [x1,y1]=pol2cart(angle,r); 
        [x2,y2]=pol2cart(err_up,r);
        [x3,y3]=pol2cart(err_down,r);
        
%     jbfill(x1,y1,y2,'b','b',1,0.5);
        x_fill = [x2(end), x1(end), x3(end), 0];
        y_fill = [y2(end), y1(end), y3(end), 0];
        
% fill(x_fill,y_fill,'r');
        patch(x_fill,y_fill,'b','facealpha',0.3);
        title(['Chan' num2str(u1(iPD,1)) ', Elec' num2str(cer_list(find(chan_list == u1(iPD,1),1,'first')))]) % last part finds the cerebus assigned label in cer_list that belongs to the channel number of the current channel
    elseif max(max(chan_list_up' == u1(iPD,1)))
        figure(h_up);
        subplot(subplot_dim_up_r,subplot_dim_up_c,find(chan_list_up' == u1(iPD,1),1,'first')) % put the plot in the correct location relative to position in array ( [ 1 2 3;..
                                                                                                                               % 4 5 6 ]; )
        h1 = polar(angle,r);
        hold on
        h2 = polar(err_up,r);
        h3 = polar(err_down,r);
        set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
            '-or','String','150','-or','String','210','-or','String','240',...
            '-or','String','300','-or','String','330','-or','String','  0.2',...
            '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
            '-or','String','  0.1','-or','String','  1') ,'String', ' ');
        
        set(h1,'linewidth',2);
        [x1,y1]=pol2cart(angle,r); 
        [x2,y2]=pol2cart(err_up,r);
        [x3,y3]=pol2cart(err_down,r);
        
%     jbfill(x1,y1,y2,'b','b',1,0.5);
        x_fill = [x2(end), x1(end), x3(end), 0];
        y_fill = [y2(end), y1(end), y3(end), 0];
        
% fill(x_fill,y_fill,'r');
        patch(x_fill,y_fill,'b','facealpha',0.3);
        title(['Chan' num2str(u1(iPD,1)) ', Elec' num2str(cer_list(find(chan_list == u1(iPD,1),1,'first')))])
    else
        disp('Error: channel not found in channel list')
    end
end

if length(varargin)>3
    plot_histogram = varargin{4};
else
    plot_histogram = 0;
end
if plot_histogram
    % plot confidence interval histograms
    figure('name','95% CI'); 
    hist(abs(errs*180/pi)*1.96*2,30)
    xlabel('degrees')
    ylabel('PD counts')
    title('Histogram of 95% confidence interval on PDs')
    
    % plot PD histograms
    figure('name','PDs')
    hist(pds*180/pi,30)
    xlabel('degrees')
    ylabel('PD counts')
    title('Histogram of PDs')
    
    % plot modulation depth histogram
    figure('name','modulation depth')
    hist(moddepth,30)
    xlabel('sqrt(a^2+b^2) where a and b are the GLM weights on x and y velocity')
    ylabel('PD counts')
    title('Histogram of PD modulation depth')
end