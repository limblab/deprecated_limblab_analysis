function [outdata,h_up,h_low,h_PD_mags,h_PD_ang_hist,h_PD_CI_hist]=PD_plot(varargin)

% PD_PLOT = PD_plot(BDF,ARRAY_MAP_FILEPATH,INCLUDE_UNSORTED,INCLUDE_HISTOGRAMS,DESELECTED_CHANNELS)
%       generates PD plots. BDF is data in the bdf structure. 
%       ARRAY_MAP_FILEPATH should be a string ; the filepath of the array mapping, or the name
%       of your monkey (only Kramer added now).
%       INCLUDE_UNSORTED allows the inclusion of unsorted units in the PD
%       calculation of different from 0. 
%       INCLUDE_HISTOGRAMS plots several histograms if different from 0. 
%       DESELECTED_CHANNELS = array of channels that won't be taken into
%       account. Deselected channels will show up red in the plot.
%
%       The polar plots show the PD as a thicker line, the length of which
%       indicates the modulation depth, scaled to the maximum of the
%       moddepths present, excluding the deselected channels.
%       The area between two 95% confidence bounds will be shaded. 



%% sort out inputs 
if strcmp(varargin{2},'Kramer')
    cerebus_array_map_filepath = '\\citadel.physiology.northwestern.edu\limblab\lab_folder\Animal-Miscellany\_Implant Miscellany\Blackrock Array Info\Array Map Files\6251-0922.cmp';
else
    cerebus_array_map_filepath = varargin{2}; 
end


bdf = varargin{1};

if length(varargin)<3
    include_unsorted = 0;
else
    include_unsorted = varargin{3}; % the third input parameter determines whether or not unsorted units are taken into account
end

if length(varargin)>3
    plot_histogram = varargin{4};
else
    plot_histogram = 0;
end

if length(varargin)>4
    deselected_chan = varargin{5};
    ul=unit_list(bdf,1); % gets two columns back, first with channel
% numbers, second with unit sort code on that channel
    for i=1:length(deselected_chan)
        if include_unsorted==0
            skipchans(i)=find(ul(:,1)==deselected_chan(i) & ul(:,2)~=0);
        else
            skipchans(i)=find(ul(:,1)==deselected_chan(i) & ul(:,2)==0);
        end
    end
else
    deselected_chan = [];
    skipchans=[];
end

% include_unsorted = 1 ; 
% cerebus_array_map_filepath = 'D:\My Documents\Uni\Master\Delft\stage\inhoud\data\Kramer implant array map\6251-0922.cmp';
% bdf = sun710;

%% get pds, standard errors and modulation depth and unit list
model='posvel';
[pds, errs, moddepth] = glm_pds(bdf,include_unsorted,model);

u1 = unit_list(bdf,1); % gets two columns back, first with channel
% numbers, second with unit sort code on that channel
if isempty(u1)
    error('S1_ANALYSIS:PROC:TUCKER:PDS:PD_PLOT:NoUnits','no units were found to compute PDs on')
end
if (include_unsorted && length(u1)~=length(moddepth))
    disp('discarding clusters')
    u1=u1(~u1(:,2),:);
end
%set_outputs
outdata=[double(u1(:,1)),pds,moddepth,errs];

%% identify channels with excessive modulation depth
for iChan = 1:length(u1)
    if (moddepth(iChan) > 10)
        warning('PD_force_plot:AbnormalModulationDepth',strcat('An unusually large modulation depth was detected on channel: ',num2str(iChan)))
        disp(strcat('Channel: ',num2str(iChan), ' has been marked as bad, and will not be used to compute the mean modulation depth'))
        deselected_chan = [u1(iChan), deselected_chan];
        skipchans=[iChan,skipchans];
    end
    if u1(iChan)>96
        deselected_chan = [u1(iChan), deselected_chan];
        skipchans=[iChan,skipchans];
    end
end
%% identify channels with low modulation depth
tmp_mean=mean(moddepth(setxor([1:length(moddepth)],skipchans)));
for iChan = 1:length(u1)
    if moddepth(iChan)< tmp_mean
        %moddepth(iChan)= 0;
        deselected_chan = [u1(iChan), deselected_chan];
        skipchans=[iChan,skipchans];
    end
end
disp(['Deselected channels (manually or because moddepth > 1 ): ' num2str(deselected_chan)])

% %% make deselected channel pds, errs and moddepth zero.
% % deselected_chan = [96];
%     
% pds(find(ismember(u1,deselected_chan))) = NaN ; 
% errs(find(ismember(u1,deselected_chan))) = NaN ; 
% moddepth(find(ismember(u1,deselected_chan))) = NaN ; 


%% PD map plot. 
% This plots polar plots showing the PDs and confidence intervals in the location of their respective channels

[chan_list,cer_list] = get_array_mapping(cerebus_array_map_filepath);
[r,c] = size(chan_list);

chan_list_up = chan_list(1:floor(r/2),:); % channel list for the upper-half plot
chan_list_low = chan_list((floor(r/2)+1):end,:);

[subplot_dim_up_r,subplot_dim_up_c]=size(chan_list_up); % subplot dimensions
[subplot_dim_low_r,subplot_dim_low_c]=size(chan_list_low); % subplot dimensions

CI = errs*1.96; % confidence bounds



h_up = figure('name','PDs upper half of array');
h_low = figure('name','PDs lower half of array');

iPD =2 ; 
maxmod=max(moddepth(setxor([1:length(moddepth)],skipchans)));
for iPD = 1:length(u1(:,1))
    if moddepth(iPD)==0;
        r=0;
    else
        r = [0.0001,moddepth(iPD)]/maxmod; % the length of the radial line is normalized by the modulation depth
    end
    angle = repmat(pds(iPD),1,length(r)); % vector size (1,length(r)) of elements equal to each preferred direction
    err_up = angle+repmat(CI(iPD),1,length(r)); % upper error bound
    err_down = angle-repmat(CI(iPD),1,length(r)); % lower error bound
    if max(max(chan_list_low' == u1(iPD,1)))
        figure(h_low);
        subplot(subplot_dim_low_r,subplot_dim_low_c,find(chan_list_low' == u1(iPD,1),1,'first')) % put the plot in the correct location relative to position in array ( [ 1 2 3;..
                                                                                                                               % 4 5 6 ]; )
        h0 = polar(pi,1); % place point at max length so all polar plots are scaled the same.
        hold on
        h1 = polar(angle,r);
        h2 = polar(err_up,r);
        h3 = polar(err_down,r);
        set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
            '-or','String','150','-or','String','210','-or','String','240',...
            '-or','String','300','-or','String','330','-or','String','  0.2',...
            '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
            '-or','String','  0.1','-or','String','  1') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential
        set(h1,'linewidth',2);
        
        if max(u1(iPD)==deselected_chan)
            % make background color red of deselected channels
            ph=findall(gca,'type','patch');
            set(ph,'facecolor',[1,0,0]);  
        end
        [x1,y1]=pol2cart(angle,r); % needed to fill up the space between the two CI
        [x2,y2]=pol2cart(err_up,r);
        [x3,y3]=pol2cart(err_down,r);

        %     jbfill(x1,y1,y2,'b','b',1,0.5);
        x_fill = [x2(end), x1(end), x3(end), 0];
        y_fill = [y2(end), y1(end), y3(end), 0];

        % fill(x_fill,y_fill,'r');
        patch(x_fill,y_fill,'b','facealpha',0.3);
        

%        title(['Chan' num2str(u1(iPD,1)) ', Elec' num2str(cer_list(find(chan_list == u1(iPD,1),1,'first')))]) % last part finds the cerebus assigned label in cer_list that belongs to the channel number of the current channel
        title(['Chan' num2str(u1(iPD,1))]) % last part finds the cerebus assigned label in cer_list that belongs to the channel number of the current channel
    elseif max(max(chan_list_up' == u1(iPD,1)))
        figure(h_up);
        subplot(subplot_dim_up_r,subplot_dim_up_c,find(chan_list_up' == u1(iPD,1),1,'first')) % put the plot in the correct location relative to position in array ( [ 1 2 3;..
                                                                                                                               % 4 5 6 ]; )
        h0 = polar(pi,1); % place point at max length so all polar plots are scaled the same.
        hold on                                                                                                                   
        h1 = polar(angle,r);
        h2 = polar(err_up,r);
        h3 = polar(err_down,r);
        set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
            '-or','String','150','-or','String','210','-or','String','240',...
            '-or','String','300','-or','String','330','-or','String','  0.2',...
            '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
            '-or','String','  0.1','-or','String','  1') ,'String', ' ');
        
        set(h1,'linewidth',2);
        if max(u1(iPD)==deselected_chan)
            % make background color red of deselected channels
            ph=findall(gca,'type','patch');
            set(ph,'facecolor',[1,0,0]);  
        end 
        [x1,y1]=pol2cart(angle,r); % needed to fill up the space between the two CI
        [x2,y2]=pol2cart(err_up,r);
        [x3,y3]=pol2cart(err_down,r);

        %     jbfill(x1,y1,y2,'b','b',1,0.5);
        x_fill = [x2(end), x1(end), x3(end), 0];
        y_fill = [y2(end), y1(end), y3(end), 0];

        % fill(x_fill,y_fill,'r');
        patch(x_fill,y_fill,'b','facealpha',0.3);
        
        
%        title(['Chan' num2str(u1(iPD,1)) ', Elec' num2str(cer_list(find(chan_list == u1(iPD,1),1,'first')))])
        title(['Chan' num2str(u1(iPD,1))])
    else
        disp('Error: channel not found in channel list')
        disp(u1(iPD,1))
    end
end

%% plot histograms

if plot_histogram
    % plot confidence interval histograms
    h_PD_CI_hist=figure('name','95% CI'); 
    
    hist(abs(errs(~isnan(errs))*180/pi)*1.96*2,[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
    xlim([0,360])
    xlabel('degrees')
    ylabel('PD counts')
    title('Histogram of 95% confidence interval on PDs')
    
    % plot PD histograms
    h_PD_ang_hist=figure('name','PDs')
    hist(pds(~isnan(pds))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
%     xlim([0,360])
    xlabel('degrees')
    ylabel('PD counts')
    title('Histogram of PDs')
    
    % plot modulation depth histogram
    h_PD_mags=figure('name','modulation depth')
    hist(moddepth(~isnan(moddepth)),30) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
    xlabel('sqrt(a^2+b^2) where a and b are the GLM weights on x and y velocity')
    ylabel('PD counts')
    title('Histogram of PD modulation depth')
end