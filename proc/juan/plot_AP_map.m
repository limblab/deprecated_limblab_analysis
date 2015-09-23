%
% Plot the shape of the APs 'à la Blackrock'
%
%       varargout = function plot_AP_map( bdf_struct );
%
%       The function takes an bdf_struct (generated from a BDF) as input.
%       If several bdf_structs are merged into an array of structs (with
%       size 1-by-N), the function will plot the AP for each of them
%       overimposed. 
%       The function returns either a handle to the figure or nothing,
%       depending of the number of arguments.
%       Note that the channels are not reorganized using an array mao.
%
%
% Last edited by Juan Gallego - Sep 16, 2015
%


function varargout = plot_AP_map( bdf_struct, varargin )


% Define if the APs will be plotted in BW or color
color_array             = ['k','r','b','g','m','c'];

% Retrieve how many BDFs we want to plot
nbr_bdfs                = numel(bdf_struct);


% Create figure handle. The figure will be 
AP_shapes_fig           = figure('units','normalized','outerposition',[0 0 1 1]);

panel_ctr               = 2;


for i = 1:nbr_bdfs
    
    for ii = 1:length(bdf_struct(i).units)

        if length(bdf_struct(i).units) <= 96

            if ( panel_ctr == 10 ) || ( panel_ctr == 91 )

                panel_ctr   = panel_ctr + 1;
            end

            mean_AP         = mean(bdf_struct(i).units(ii).waveforms);
            std_AP          = std(double(bdf_struct(i).units(ii).waveforms));

            subplot(10,10,panel_ctr),
            %            plot(bdf_struct.units(i).waveforms','color',[.5 .5 .5]);

            hold on, plot(mean_AP,'color',color_array(i),'linewidth',1);
            plot(mean_AP+std_AP,'color',color_array(i),'linewidth',1,'linestyle','-.');
            plot(mean_AP-std_AP,'color',color_array(i),'linewidth',1,'linestyle','-.');

            panel_ctr       = panel_ctr + 1;
            
            if ii == 1
                ylabel('ch 1');
            elseif rem(ii-9,10) == 0
                ylabel(['ch ' num2str(ii)])
            end
            
            if ii >= 89
                xlabel(['ch ' num2str(ii)])
            end
        else

            disp('ToDo');
        end
    end
    
    panel_ctr               = 2;
end


if nargout == 1

    varargout{1}        = AP_shapes_fig;
elseif nargout > 1
   
    error('ERROR: the function only takes 1 output argument');
end
