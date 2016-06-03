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
%             bdf = get_nev_mat_data([folder options.prefix],options.labnum,'nokin','noforce');
            bdf = get_nev_mat_data([folder options.prefix],options.labnum,'noforce');
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

        num_units = length(which_units);
        
        %area 2 info
        firing_unint = [1 3 5 10 15 29 33];
        firing_inc = [11 16 17 20 22 32 36 40 48 49];
        firing_dec = [2 7 8 12 18 19 24 25 26 29];
        which_unit_want_rw = [4 13 25 51 53];
        which_unit_want = [2 8 17 33 36];
        

%         for i=1:num_units
        
%         figure_title = strcat(options.figure_title,' Unit ',num2str(i));
%         figure_title = strcat(options.figure_title, '1');
%         h = figure('name',figure_title);
%         figure_handles = [figure_handles h];
%         
        
        %VIBRATION TRACE
        
        
%         norm_analog_data = bdf.analog.data/max(abs(bdf.analog.data));
%         subplot(num_units+1,1,1)
% %          subplot(3,1,1)
% 
%         plot(bdf.analog.ts',norm_analog_data,'-b');
%         xlim([0 100])

         % RASTOR PLOT FOR SPECIFIC UNITS
         
% % % %          figure_title = strcat(options.figure_title,'Units with increase in firing');
% % % %          h = figure('name',figure_title);
% % % %          figure_handles = [figure_handles h];
% % % %          
% % % %          
% % % % %          subplot(stop+1,1,1)
% % % %  
% % % %          plot(bdf.analog.ts',bdf.analog.data/max(abs(bdf.analog.data)),'-b');
% % % %          hold on
% % % %          
% % % %          stop = length(firing_unint);
% % % %          for i=1:stop
% % % %              k = firing_unint(i);
% % % %              spike_times = bdf.units(which_units(k)).ts; 
% % % %               plot(spike_times,i/10+.75,'k.', 'markersize', 4)
% % % %          end
% % % %          
% % % %          stop = length(firing_inc);
% % % %          for i=1:stop
% % % %              k = firing_inc(i);
% % % %              spike_times = bdf.units(which_units(k)).ts; 
% % % %               plot(spike_times,i/10+2,'k.', 'markersize', 4)
% % % %          end
% % % %          
% % % %          stop = length(firing_dec);
% % % %          for i=1:stop
% % % %              k = firing_dec(i);
% % % %              spike_times = bdf.units(which_units(k)).ts; 
% % % %               plot(spike_times,i/10+3.5,'k.', 'markersize', 4)
% % % %          end
% % % %          
% % % %          ylim([-1 5])
         
        % GAUSSIAN CONVOLUTION FOR FREQUENCY
        
        for i=1:num_units
%         for k=1:stop
%             i = firing_inc(k);

% % %            subplot(3,1,2)
% % % 
% % %            spikes(:,1) = bdf.analog.ts;
% % %            spikes(:,2) = 0;
% % %            unit_ts_rounded = round(bdf.units(which_units(i)).ts*1000)/1000;
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
% % %             G = fspecial('gaussian', [150,1], 60);
% % %             data_conv = conv(spikes(:,2), G, 'same');
% % %             data_conv_norm = data_conv/(max((abs(data_conv))));
% % % %             plot(spikes(:,1),data_conv_norm*.95+i, 'g')
% % %             plot(spikes(:,1),data_conv, 'g')


%             subplot(stop+1,1,k+1)
%              subplot(3,1,3)
            subplot(num_units+1,1,i)
            unit_ts_rounded = round(bdf.units(which_units(i)).ts*1000)/1000;
             firing_rate = calcFR(bdf.analog.ts,unit_ts_rounded,.3, 'gaussian');
            spike_times = bdf.units(which_units(i)).ts; 
            
            plot(bdf.analog.ts,firing_rate,'g')
            hold on
            plot(spike_times,20,'k.', 'markersize', 4)
            ylim([0 50])
            xlim([0 100])
            title(strcat('Unit ', num2str(i)))

        end
         
         
        figure_title = strcat(options.figure_title,'Position Reference');
        h = figure('name',figure_title);
        figure_handles = [figure_handles h];
        
        %POSITION AND VELOCITY FOR RW
        
%         subplot(2,1,1)
        
%         plot(bdf.pos(:,1),bdf.pos(:,2))
%         hold on
%         plot(bdf.pos(:,1),bdf.pos(:,3),'g')


        %BASIC RASTOR PLOT OVER VIBRATION
         
        
        plot(bdf.analog.ts',bdf.analog.data/max(abs(bdf.analog.data)),'-b');
        hold on
        
%         subplot(2,1,2)
        
        for i=1:length(which_unit_want)
            
            k = which_unit_want(i);
%             spike_times = bdf.units(which_units(i)).ts; 
            spike_times = bdf.units(which_units(k)).ts; 
            
            plot(spike_times,i,'k.', 'markersize', 4)
            hold on
            ylim([0 6])
        end
        
%          labels = strcat(repmat({'Unit '},num_units,1),cellstr(strtrim(num2str((1:num_units)'))))';
%          labels = [{'Vibration'} labels];
%          set(gca,'ylim',[-1 i+1],'ytick',0:i,'yticklabels',labels,'tickdir','out')

        
        % STA ANALYSIS 
            % 20ms before and after spike occurs
        
        %NEED TO COMPUTE CONFIDENCE BOUNDS
        
% %         figure_title = strcat(options.figure_title,' 3');
% %         h = figure('name',figure_title);
% %         figure_handles = [figure_handles h];
% %         
% %         sta_norm=zeros(41,num_units);
% %         
% %         for i=1:num_units %for each unit
% %             spike_times = bdf.units(which_units(i)).ts; %vector or spike times
% %             st_rounded = round(bdf.units(which_units(i)).ts*1000)/1000; %round to match sig fig of analog signal
% %             sta_matrix = zeros(length(st_rounded),41);
% %             sta=zeros(41,1);
% % 
% %             
% %             for k=1:length(st_rounded) %for each spike time
% % 
% %                 for m=1:length(bdf.analog.ts) %check each time point of the analog vibration signal
% %                     
% %                     if(bdf.analog.ts(m)==st_rounded(k) && m-20>0 && m+20<length(bdf.analog.ts)) %if the analog time point matches spike time, store analog.data 40ms snippet in new col. in matrix
% %                        sta_matrix(k,:) = bdf.analog.data(m-20:m+20);
% %                     end
% %                 end
% %             end
% %             for n=1:41
% %                sta(n) = mean(sta_matrix(:,n));   
% %             end
% %             
% %             t = linspace(-.02,.02,41);
% %             plot(t,sta)
% %             yL = get(gca,'YLim');
% %             line([0 0],yL,'Color','k');
% %             hold all
% %             
% % %             sta_norm(:,i) = sta;
% %         end
        
%         sta_norm = sta_norm/max(max(abs(sta_norm)));
% 
%         for i=1:num_units
%             t = linspace(-.02,.02,41);
%             plot(t,sta_norm(:,i))
%             yL = get(gca,'YLim');
%             line([0 0],yL,'Color','k');
%             hold all
%         end
                
        
        % INSTANTANEOUS FREQUENCY
        
% %         figure_title = strcat(options.figure_title,'4');
% %         h = figure('name',figure_title);
% %         figure_handles = [figure_handles h];
% %         
% %         for i=1:1 
% %             
% %             length_ts = length(bdf.units(which_units(i)).ts);       
% %             inst_freq = zeros(length_ts,3);
% %             
% %             for k=2:length_ts
% %                 
% %                 inst_freq(k,1) = bdf.units(which_units(i)).ts(k);
% %                 inst_freq(k,2) = (bdf.units(which_units(i)).ts(k) - bdf.units(which_units(i)).ts(k-1)); %interspike interval
% %                 inst_freq(k,3) = 1/inst_freq(k,2);
% %                 
% %             end
% %             
% %             
% %             plot(bdf.analog.ts',bdf.analog.data/max(abs(bdf.analog.data)),'-b')
% %             hold on
% %             plot(inst_freq(2:length_ts,1),inst_freq(2:length_ts,3),'r')
% %             hold all
% %         end

            %FFT
%             
%             Y = fft(bdf.analog.data');
%             data_length=length(bdf.analog.data);
% 
%             P2 = abs(Y/data_length);
%             P1 = P2(1:data_length/2+1);
%             P1(2:end-1) = 2*P1(2:end-1);
% 
%             f = 1000*(0:(data_length/2))/data_length;
% 
%             figure_title = strcat(options.figure_title, 'fft of analog data signal for biceps sweep');
%             h = figure('name',figure_title);
%             figure_handles = [figure_handles h];
%             
%             plot(f(15:end),P1(15:end))
%             title('fft of analog data signal for biceps sweep')
%             xlabel('frequency (Hz)')
%             ylabel('|P1(f)|')
        
        
        
        
        
        
        
        
  
    catch MExc
        output_data.MExc = MExc;
        warning('Code did not fully execute. Check ''MExc'' in output data for more information.')
    end
end
