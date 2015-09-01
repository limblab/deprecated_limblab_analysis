%
% Plot the shape of the APs 'à la Blackrock'
%
%       varargout = function plot_AP_map( out_struct );
%
%       The function takes an out_struct (generated from a BDF) as input. 
%       The function returns either a handle to the figure or nothing,
%       depending of the number of arguments
%
%
% Last edited by Juan Gallego - Dec 16, 2014
%


function varargout = plot_AP_map( out_struct )


% Define if the APs will be plotted in BW or color
color_plot_yn           = 1;




% Create figure handle. The figure will be 
AP_shapes_fig           = figure('units','normalized','outerposition',[0 0 1 1]);




panel_ctr               = 2;


for i = 1:length(out_struct.units)
    
    
    if length(out_struct.units) <= 96
        
        if color_plot_yn == 1
        
            colors_AP_plot  = colormap(jet(96));
        end
        
        
        if ( panel_ctr == 10 ) || ( panel_ctr == 91 )
            
            panel_ctr   = panel_ctr + 1;
        end
        
        mean_AP         = mean(out_struct.units(i).waveforms);
        std_AP          = std(double(out_struct.units(i).waveforms));
        
        subplot(10,10,panel_ctr),
        %            plot(out_struct.units(i).waveforms','color',[.5 .5 .5]);
        
        if color_plot_yn == 0
        
            hold on, plot(mean_AP,'color','k','linewidth',1);
            plot(mean_AP+std_AP,'color','k','linewidth',1,'linestyle','-.');
            plot(mean_AP-std_AP,'color','k','linewidth',1,'linestyle','-.');
        else
            
            hold on, plot(mean_AP,'color',colors_AP_plot(i,:),'linewidth',1);
            plot(mean_AP+std_AP,'color',colors_AP_plot(i,:),'linewidth',1,'linestyle','-.');
            plot(mean_AP-std_AP,'color',colors_AP_plot(i,:),'linewidth',1,'linestyle','-.');
        end
        
        panel_ctr       = panel_ctr + 1;
    else
        
        disp('ToDo');
    end
end


if nargout == 1

    varargout{1}        = AP_shapes_fig;
elseif nargout > 1
   
    error('ERROR: the function only takes 1 output argument');
end
