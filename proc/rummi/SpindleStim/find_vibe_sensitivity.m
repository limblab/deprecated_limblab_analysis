function [figure_handles, output_data]=find_vibe_sensitivity(folder,options)
    try
        %%
        figure_handles=[];
%         figure_t = figure_title;

    %     matfilelist=dir([folder filesep options.prefix '*.mat']);
    %     nevfilelist=dir([folder filesep options.prefix '*.nev']);
    %     if ~isempty(matfilelist)
    %         temp=load([folder filesep matfilelist(1).name]);
    %         y=fieldnames(temp);
    %         if length(y)==1
    %             NSx=temp.(y{1});
    %         else
    %             error('get_PDs: loaded multiple variables from .mat file')
    %         end
    %     elseif ~isempty(nevfilelist)
    %         NSx=cerebus2NEVNSx(folder,options.prefix);
    %     else
    %         error('get_PDs:found no matching files')
    %     end
        if(~isfield(options,'bdf') || ~isfield(options,'bdf'))
            if(folder(end)~=filesep)
                folder = [folder filesep];
            end
            bdf = get_nev_mat_data([folder options.prefix],options.labnum,'nokin','noforce');
        else
            bdf = options.bdf;
        end
        %% prep bdf
        %add firing rate to the units fields of the bdf
        opts.binsize=0.05;
        opts.offset=-.015;
        opts.do_trial_table=0;
        opts.do_firing_rate=1;
        bdf=postprocess_bdf(bdf,opts);
        output_data.bdf=bdf;
        
        if(isfield(options,'which_units'))
            which_units = options.which_units;
        elseif options.only_sorted
            for i=1:length(bdf.units)
                temp(i)=bdf.units(i).id(2)~=0 && bdf.units(i).id(2)~=255; %==0 for multi unit channels
            end
            ulist=1:length(bdf.units);
            which_units=ulist(temp);
        end

        %% FIGURES
        figure_handles = [];
        figure_title = strcat(options.figure_title,'1');
        
        % BASIC RASTOR PLOT OVER VIBRATION
        
        h = figure('name',figure_title);
        figure_handles = [figure_handles h];
        
        plot(bdf.analog.ts',bdf.analog.data/max(abs(bdf.analog.data)),'-b');
        hold on
        
        num_units = length(which_units);
        for i=1:num_units
            spike_times = bdf.units(which_units(i)).ts; 
            plot(spike_times,i,'k.')'
        end
        
        labels = strcat(repmat({'Unit '},num_units,1),cellstr(strtrim(num2str((1:num_units)'))))';
        labels = [{'Vibration'} labels];
        set(gca,'ylim',[-1 i+1],'ytick',0:i,'yticklabels',labels,'tickdir','out')
        
        % GAUSSIAN CONVOLUTION
        
        for i=1:num_units
            
           spikes(:,1) = bdf.analog.ts;
           spikes(:,2) = 0;
           unit_ts_rounded = round(bdf.units(which_units(i)).ts*1000)/1000;

            for m=1:length(unit_ts_rounded)
               for n=1:length(spikes)
                  if(spikes(n,1) == unit_ts_rounded(m))
                     spikes(n,2) = 1;
                  else
                  end
               end
            end
            
            G = fspecial('gaussian', [150,1], 60);
            data_conv = conv(spikes(:,2), G, 'same');
            
            data_conv_norm = data_conv/(max((abs(data_conv))));
            plot(spikes(:,1),data_conv_norm*.95+i, 'g')
        end
      
        % FFT OF SPIKES AND VIBRATION
        
% % %         figure_title = strcat(options.figure_title,'2');
% % %         h = figure('name',figure_title);
% % %         figure_handles = [figure_handles h];
% % %         
% % %         data_length = length(bdf.analog.data);
% % %         Y1 = fft(bdf.analog.data)';
% % % 
% % %         P2 = abs(Y1/data_length);
% % %         P1 = P2(1:data_length/2+1);
% % %         P1(2:end-1) = 2*P1(2:end-1);
% % % 
% % %         f1 = 1000*(0:(data_length/2))/data_length;
% % % 
% % %         plot(f1(3:end),P1(3:end)/max(abs(P1)),'k')
% % %         hold on
% % %         
% % %         for k=1:num_units
% % %            spikes(:,1) = bdf.analog.ts;
% % %            spikes(:,2) = 0;
% % %            unit_ts_rounded = round(bdf.units(which_units(k)).ts*1000)/1000;
% % %            
% % % 
% % %             for m=1:length(unit_ts_rounded)
% % %                for n=1:length(spikes)
% % %                   if(spikes(n,1) == unit_ts_rounded(m))
% % %                      spikes(n,2) = 1;
% % %                   else
% % %                   end
% % %                end
% % %             end
% % %            
% % %         Y2 = fft(spikes(:,2))';
% % % 
% % %         P2 = abs(Y2/data_length);
% % %         P1 = P2(1:data_length/2+1);
% % %         P1(2:end-1) = 2*P1(2:end-1);
% % % 
% % %         f2 = 1000*(0:(data_length/2))/data_length;
% % % 
% % %         plot(f2(3:end),P1(3:end)/max(abs(P1))+k)
% % %         hold all
% % %         end
        
        % STA - 20ms before and after spike occurs
        figure_title = strcat(options.figure_title,' 3');
        h = figure('name',figure_title);
        figure_handles = [figure_handles h];
        
        for i=1:num_units %for each unit
            spike_times = bdf.units(which_units(i)).ts; %vector or spike times
            st_rounded = round(bdf.units(which_units(i)).ts*1000)/1000; %round to match sig fig of analog signal
            sta_matrix = zeros(length(st_rounded),41);
            sta=zeros(41,1);

            
            for k=1:length(st_rounded) %for each spike time

                for m=1:length(bdf.analog.ts) %check each time point of the analog vibration signal
                    
                    if(bdf.analog.ts(m)==st_rounded(k) && m-20>0 && m+20<length(bdf.analog.ts)) %if the analog time point matches spike time, store analog.data 40ms snippet in new col. in matrix
                       sta_matrix(k,:) = bdf.analog.data(m-20:m+20);
                    end
                end
            end
            for n=1:41
               sta(n) = mean(sta_matrix(:,n));   
            end
            
            t = linspace(-.02,.02,41);
            
            
            plot(t,sta)
            yL = get(gca,'YLim');
            line([0 0],yL,'Color','k');
            hold all
            
        end
        

        % ISI - to do
        
        
        % MULTI-UNIT ANALYSIS
        
        
        
        
        
        
  
    catch MExc
        output_data.MExc = MExc;
        warning('Code did not fully execute. Check ''MExc'' in output data for more information.')
    end
end
