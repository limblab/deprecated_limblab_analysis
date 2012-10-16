function PD_plot_selection(varargin)

%  PD_PLOT_SELECTION(CHANNEL_SELECTION,INCLUDE_UNSORTED,BDF1,BDF2,...)
%       generates a polar plot showing the PDs of selected channels as 
%       thicker lines, the area between the 95% confidence bounds as
%       shaded, and the length of the lines indicating the modulation depth
%       of the PDs.
%       It plots the selected channels for different inputted BDFs, and
%       gives all channels of one BDF a different color. Theoretically, you
%       can input as many BDFs as you want, but I've only listed 6 colors
%       at the moment, so the limits at 6 now (16 oct 2012).
%       CHANNEL_SELECTION: an array of selected channels (e.g. [78, 82, 3])
%       INCLUDE_UNSORTED has to be 0 (don't include), or 1 (include
%       unsorted channels in the analysis).
%        


% varargin = {[1 2 3],1,wed1010,wed1010_half,wed1010_quarter};

for iBdf = 3:length(varargin)
    eval(['bdf' num2str(iBdf-2) ' = varargin{iBdf};']); % get bdf's, give them a name
end
channel_selection = varargin{1}; % vector of channels you want plotted: [13, 15, 94]
include_unsorted = varargin{2};

%% get pds, errs, moddepth, unit list
% [pds, errs, moddepth] = glm_pds(bdf,include_unsorted);
% u1 = unit_list(bdf,include_unsorted);

% CI = errs*1.96; % confidence bounds

for iBdf = 1:length(varargin)-2
    eval(['[pds' num2str(iBdf) ', errs' num2str(iBdf) ', moddepth' num2str(iBdf) ']=glm_pds(bdf' num2str(iBdf) ',include_unsorted);']); % calculates pds, errs and moddepths for each bdf
    eval(['u' num2str(iBdf) '= unit_list(bdf' num2str(iBdf) ',include_unsorted);']); % calculates a unit list for each bdf
    eval(['CI' num2str(iBdf) '=errs' num2str(iBdf) '*1.96;']); % get confidence bounds
end



%% make plots

% admin
figure('name','PDs of selected channels')

str = strtrim(cellstr(int2str(channel_selection.'))); % for the labels of the channels later
colors = ['b','r','k','y','c','g']; % colors of BDFs
bdf_label_angle = 50*pi/180 ; % [radians] start angle for BDF label in plot

% to set scaling of polar plot so that the largest of the modulation depths
% that we'll plot is shown, we need this:
for iBdf = 1:length(varargin)-2
    eval(['moddepth = moddepth' num2str(iBdf) ';']); % name the moddepth
    eval(['u = u' num2str(iBdf) ';']); % name the unit list to work with here
    
    for iChan=1:length(channel_selection)
        iPD = find(u == channel_selection(iChan),1,'first');
        moddepth_scaling(iChan) = moddepth(iPD);
    end
    scaling_factor(iBdf) = max(moddepth_scaling); % get the max moddepth
end
scaling_factor = max(scaling_factor); % get max moddepth of all selected channels in all bdfs that will be plotted

% actual plot

for iBdf = 1:length(varargin)-2
    eval(['u = u' num2str(iBdf) ';']); % name the unit list to work with here
    eval(['pds_here = pds' num2str(iBdf) ';']); % name the pds
    eval(['CI = CI' num2str(iBdf) ';']); % name the CIs
    eval(['moddepth = moddepth' num2str(iBdf) ';']); % name the moddepth
    
    for iChan=1:length(channel_selection)
        iPD = find(u == channel_selection(iChan),1,'first');
        r = 0.0001:0.0001:moddepth(iPD); % /max(moddepth); % the length of the radial line is normalized by the modulation depth
        angle = repmat(pds_here(iPD),1,length(r)); % vector size (1,length(r)) of elements equal to each preferred direction
        err_up = angle+repmat(CI(iPD),1,length(r)); % upper error bound
        err_down = angle-repmat(CI(iPD),1,length(r)); % lower error bound
        
        h0 = polar(pi,scaling_factor); % plot this dot to fix scale of plot so that all lines are visible
        hold on
        h1 = polar(angle,r, colors(iBdf)); 
        h2 = polar(err_up,r, colors(iBdf));
        h3 = polar(err_down,r, colors(iBdf));
        set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
            '-or','String','150','-or','String','210','-or','String','240',...
            '-or','String','300','-or','String','330') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential
        
        %         '-or','String','  0.2',...
        %             '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
        %             '-or','String','  0.1','-or','String','  1',...
        %             '-or','String','  0.4','-or','String','  0.6',...
        %             '-or','String','  0.8'
        
        set(h1,'linewidth',2 )% ,'color',colors(iBdf));
        [x1,y1]=pol2cart(angle,r); % needed to fill up the space between the two CI
        [x2,y2]=pol2cart(err_up,r);
        [x3,y3]=pol2cart(err_down,r);
        [x0,y0]=pol2cart(bdf_label_angle,scaling_factor+scaling_factor/4);
        
        x_fill = [x2(end), x1(end), x3(end), 0];
        y_fill = [y2(end), y1(end), y3(end), 0];
        patch(x_fill,y_fill,colors(iBdf),'facealpha',0.3,'edgecolor',colors(iBdf));
        
        % channel labels
        text(x1(end)+x1(end)/5,y1(end)+y1(end)/5,str{iChan}); % this labels the lines with their channel numbers
        
        % bdf labels
        text(x0,y0,['BDF' num2str(iBdf)],'color',colors(iBdf),'fontsize',13)
        
    end
    bdf_label_angle = bdf_label_angle - 7*pi/180;
end