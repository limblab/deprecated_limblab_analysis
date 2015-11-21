%
% Plot the shape of the APs
%
%       The function takes an bdf_struct (generated from a BDF) as input.
%       Several bdf_structs can be merged into an array of structs. 
%       The function returns either a handle to the figure.
%       Note that the channels are not reorganized using an array map.
%
%       PLOT_AP_MAP( bdf_struct, plot_std ): plot_std defines whether the
%       SD of the AP shape will be plotted 
%       PLOT_AP_MAP( bdf_struct, array_map_file): array_map is the path to
%       the map file provided by Blackrock  
%       PLOT_AP_MAP( bdf_struct, ch_nbr ): ch_nbr is an array that defines
%       the channels that will be plotted. 
%       PLOT_AP_MAP( bdf_struct, array_map_file, plot_std ): array_map is
%       the path to the map file provided by Blackrock 
%       PLOT_AP_MAP( bdf_struct, ch_nbr, plot_std ): ch_nbr is an array
%       that defines the channels that will be plotted.
%
% Last edited by Juan Gallego - Sep 16, 2015
%


function varargout = plot_AP_map( bdf_struct, varargin )


% parameters
if nargin == 2
    if islogical(varargin{1})
        plot_std        = varargin{1};
    elseif isnumeric(varargin{1})
        ch_nbrs         = varargin{1};
    elseif ischar(varargin{1})
        array_map_file  = varargin{1};
    end
elseif nargin == 3
    if isnumeric(varargin{1})
        ch_nbrs         = varargin{1};
    elseif ischar(varargin{1})
        array_map_file  = varargin{1};
    end
    plot_std            = varargin{2};
end

% set missing params to defaults
if ~exist('plot_std','var')
    plot_std            = true;
end

% -------------------------------------------------------------------------
% Create an array with the channels that will be plotted
if ~exist('ch_nbrs','var')
    ch_nbrs             = 1:length(bdf_struct(1).units);
end

% Define colors for each of the files
color_array             = ['k','r','b','g','m','c'];

% Read how many BDFs we want to plot
nbr_bdfs                = numel(bdf_struct);

% If an array_map file was passed, use it
if exist('array_map_file','var')
   if iscell(array_map_file)
       nbr_arr_map_files = numel(array_map_file);
   else
       nbr_arr_map_files = 1;
   end
   % if several map files have been passed, each of them will be assigned
   % to a different BDF. If not, the same will be used for all BDFs
   if nbr_arr_map_files > 1
       if nbr_arr_map_files ~= nbr_bdfs
           error('ERROR: The number of array_map files does not match the name of BDFs');
       end
       for i = 1:nbr_arr_map_files
          bdf_struct(i).map  = get_array_mapping(array_map_file{i});
       end
   else
       for i = nbr_bdfs
          bdf_struct(i).map  = get_array_mapping(array_map_file);
       end
   end      
end



% -------------------------------------------------------------------------
% The plot itself

% Figure handle
AP_shapes_fig           = figure('units','normalized','outerposition',[0 0 1 1]);


for i = 1:nbr_bdfs

    if ~exist('array_map_file','var')

        panel_ctr           = 2;

        for ii = 1:length(ch_nbrs)
            if length(ch_nbrs) <= 36

                mean_AP     = mean(bdf_struct(i).units(ii).waveforms);
                std_AP      = std(double(bdf_struct(i).units(ii).waveforms));

                subplot(6,6,panel_ctr-1),
                if plot_std
                    hold on, plot(mean_AP,'color',color_array(i),'linewidth',1);
                    plot(mean_AP+std_AP,'color',color_array(i),'linewidth',1,'linestyle','-.');
                    plot(mean_AP-std_AP,'color',color_array(i),'linewidth',1,'linestyle','-.');
                else
                    hold on, plot(mean_AP,'color',color_array(i),'linewidth',2);
                end

                panel_ctr   = panel_ctr + 1;

                if ii == 1
                    ylabel('ch 1');
                elseif rem(ii-1,6) == 0
                    ylabel(['ch ' num2str(ii)])
                end

                if ii >= 31
                    xlabel(['ch ' num2str(ii)])
                end

            elseif length(ch_nbrs) <= 49

                mean_AP     = mean(bdf_struct(i).units(ii).waveforms);
                std_AP      = std(double(bdf_struct(i).units(ii).waveforms));

                subplot(7,7,panel_ctr-1),
                if plot_std
                    hold on, plot(mean_AP,'color',color_array(i),'linewidth',1);
                    plot(mean_AP+std_AP,'color',color_array(i),'linewidth',1,'linestyle','-.');
                    plot(mean_AP-std_AP,'color',color_array(i),'linewidth',1,'linestyle','-.');
                else
                    hold on, plot(mean_AP,'color',color_array(i),'linewidth',2);
                end

                panel_ctr   = panel_ctr + 1;

                if ii == 1
                    ylabel('ch 1');
                elseif rem(ii-1,7) == 0
                    ylabel(['ch ' num2str(ii)])
                end

                if ii >= 43
                    xlabel(['ch ' num2str(ii)])
                end

            elseif length(ch_nbrs) <= 96

                if ( panel_ctr == 10 ) || ( panel_ctr == 91 )

                    panel_ctr   = panel_ctr + 1;
                end

                mean_AP     = mean(bdf_struct(i).units(ii).waveforms);
                std_AP      = std(double(bdf_struct(i).units(ii).waveforms));

                subplot(10,10,panel_ctr),
                if plot_std
                    hold on, plot(mean_AP,'color',color_array(i),'linewidth',1);
                    plot(mean_AP+std_AP,'color',color_array(i),'linewidth',1,'linestyle','-.');
                    plot(mean_AP-std_AP,'color',color_array(i),'linewidth',1,'linestyle','-.');
                else
                    hold on, plot(mean_AP,'color',color_array(i),'linewidth',2);
                end

                panel_ctr   = panel_ctr + 1;

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
    % if we have passed an array file    
    else
        
    end
end

% -------------------------------------------------------------------------
% return the handle
if nargout == 1

    varargout{1}        = AP_shapes_fig;
elseif nargout > 1
   
    error('ERROR: the function only takes 1 output argument');
end
