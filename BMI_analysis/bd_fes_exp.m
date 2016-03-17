function varargout = bd_fes_exp(varargin)

% this function is to calculate and plot successful FES and catch rate,
% BDF files are required to be loaded. Results will be both displayed on
% screen and saved in the struct.

if nargin >= 1
    datapath = varargin{1};
    if nargin >=2
        plotflag = varargin{2};
    end
else
    plotflag = 1;
    datapath = 'C:\Monkey\Jaco\Data\BDFStructs\';
end

%% Compile FES Results from BDF files
[FES_files, pathname] = uigetfile([datapath '*.mat'], 'Please select FES Files','MultiSelect','on');

if ischar(FES_files)
    numfiles = 1;
    FES_files = {FES_files};
elseif iscell(FES_files)
    numfiles = length(FES_files);
else
    varargout = {[]};
    return;
end
    
fes_stats = zeros(numfiles,14);
% columns are:
% 1-time_start
% 2-time_end
% 3-fes_rew
% 4-fes_abort
% 5-fes_fail
% 6-fes_incomp
% 7-total_fes
% 8-catch_rew
% 9-catch_abort
% 10-catch_fail
% 11-catch_incomp
% 12-total_catch
% 13-fes_rate
% 14-catch_rate

t0=[];
overall_fes_rew = 0;
overall_num_fes = 0;
overall_catch_rew=0;
overall_num_catch=0;

%calculate and plot
for i=1:numfiles
    
    bdf = LoadDataStruct([pathname FES_files{i}]);
    
    t_end = datevec(bdf.meta.datetime); %time file was last modified.
    t_start = t_end - [0 0 0 0 0 round(bdf.meta.duration)]; %end - [y,m,d,h,mi,s]
    
    if isempty(t0)
        t0 = t_start;
        t_start = 0;
    else
        t_start = etime(t_start,t0)/60;
    end
        t_end = t_start+round(bdf.meta.duration)/60;
    
    if isfield(bdf,'words')
        
        tt = bd_trial_table(bdf);

        fes_rew    = sum(tt(:,4)==0 & tt(:,7)==double('R'));
        fes_abort  = sum(tt(:,4)==0 & tt(:,7)==double('A'));
        fes_fail   = sum(tt(:,4)==0 & tt(:,7)==double('F'));
        fes_incomp = sum(tt(:,4)==0 & tt(:,7)==double('I'));
        total_fes  = fes_rew+fes_incomp;
        catch_rew    = sum(tt(:,4)==1 & tt(:,7)==double('R'));
        catch_abort  = sum(tt(:,4)==1 & tt(:,7)==double('A'));
        catch_fail   = sum(tt(:,4)==1 & tt(:,7)==double('F'));
        catch_incomp = sum(tt(:,4)==1 & tt(:,7)==double('I'));    
        total_catch  = catch_rew+catch_incomp;
        
        if(total_fes>0)
            fes_rate   = 100*fes_rew/total_fes;
            overall_fes_rew = overall_fes_rew+fes_rew;
            overall_num_fes = overall_num_fes+total_fes;
        else
            fes_rate = -1;
        end
        if(total_catch>0)
            catch_rate = 100*catch_rew/total_catch;
            overall_catch_rew=overall_catch_rew+catch_rew;
            overall_num_catch=overall_num_catch+total_catch;
        else
            catch_rate = -1;
        end
        
        fes_stats(i,:) = [t_start t_end fes_rew fes_abort fes_fail ...
                          fes_incomp total_fes catch_rew catch_abort ...
                          catch_fail catch_incomp total_catch ...
                          fes_rate catch_rate];
    else        
        disp(sprintf('File "%s" contained no words',FES_files{i}));
        def_results = zeros(1,10);
        fes_stats(i,:) = [t_start t_end def_results -1 -1];
    end
    clear bdf;
    overall_fes_rate  =100*overall_fes_rew/overall_num_fes;
    overall_catch_rate=100*overall_catch_rew/overall_num_catch;
end

varargout = {{FES_files', fes_stats}};

if plotflag

    fh = figure;
    time_axes = gca;
    xlim([min(fes_stats(:,1))-15 max(fes_stats(:,2))+5]);
    ylim([-5 110]);
    hold on;
    for i=1:numfiles
        x1 = (fes_stats(i,1)-fes_stats(1,1));
        x2 = (fes_stats(i,2)-fes_stats(1,1));
        fes_rate = fes_stats(i,13);
        catch_rate = fes_stats(i,14);
        if (fes_rate >= 0)
            plot( [x1 x2], [fes_rate fes_rate],'g','LineWidth',5);
        end
        if (catch_rate>=0)
            if ( abs(fes_rate-catch_rate) <=3)  %thin line
                plot( [x1 x2], [catch_rate catch_rate],'b','LineWidth',2);
            else %thick line
                plot( [x1 x2], [catch_rate catch_rate],'b','LineWidth',5);
            end
        end
    end
    legend('FES %','Catch %','Location','NorthWest');
    xlabel('Time(min)');
    ylabel('Success Rate (%)');
    title(FES_files{1,1}(1:end-3));
    
    set(time_axes,'Position',[0.07 0.11 0.63 0.815]);
    
    Position = [0.725 0.11 0.25 0.815];
    ave_axis = axes('Position',Position);
    bar(1,overall_fes_rate,'g');
    hold on;
    bar(2, overall_catch_rate,'b');
    xlim([0.4 2.6]);
    ylim([0 105]);
end




%  
%     
%     if i+1 <=length(filename)
%         load([pathname filename{i+1}])
%         
%         %time2 is the beginning of the next trial
%         time2=out_struct.meta.datetime;
%         temp=time2-time1;
%     end
%     
%     %the duration between two trials, no result will be shown
%     if temp(17)<0
%         temp(17)=10+temp(17);
%         temp(16)=temp(16)-1;
%     end
%     if temp(16)<0
%         temp(16)=6+temp(16);
%         temp(14)=temp(14)-1;
%     end
%     if temp(14)<0
%         temp(14)=10+temp(14);
%         temp(13)=temp(13)-1;
%     end
%     if temp(13)<0
%         temp(13)=6+temp(13);
%     end 
%     if temp(13)>=0 && temp(14)>=0 && temp(16)>=0 && temp(17)>=0
%         gap=temp(13)*10+temp(14)+(temp(16)*10+temp(17))/60-dur;
%     end    
% 
%     %print out
%     fprintf('%s',filename{i});
%     fprintf('   %8s',num2str(dur));
%     fprintf('        %3s',num2str(rwd_FES));
%     fprintf('        %2s',num2str(fail_FES));
%     fprintf('        %2s',num2str(abort_FES));
%     fprintf('        %2s',num2str(incmp_FES));
%     fprintf('      %7s',num2str(suc_FES));    
%     fprintf('        %2s',num2str(rwd_catch));
%     fprintf('        %2s',num2str(fail_catch));
%     fprintf('        %2s',num2str(abort_catch));
%     fprintf('        %2s',num2str(incmp_catch));
%     fprintf('      %7s\n',num2str(suc_catch)); 
%     disp('------------------------------------------------------------------------------------------------------------------------------------------------');
%     
%     %save the results
%     filename{i} = struct('file', {filename{i}}, 'duration', {num2str(dur)}, 'reward_FES', {num2str(rwd_FES)}, 'fail_FES', {num2str(fail_FES)}, 'abort_FES', {num2str(abort_FES)},...
%         'incomplete_FES', {num2str(incmp_FES)}, 'successful_FES_rate', {num2str(suc_FES)}, 'reward_catch', {num2str(rwd_catch)}, 'fail_catch',{num2str(fail_catch)},...
%         'abort_catch', {num2str(abort_catch)}, 'incomplete_catch', {num2str(incmp_catch)}, 'successful_catch_rate', {num2str(suc_catch)}); 
%     
%     t_st=t_end+gap;
%  
% end
% 
% 
% % % 
% % % %initiation
% % % t_st=0;
% % % matrix=zeros(length(filename),2);
% % % i=1;
% % % disp('------------------------------------------------------------------------------------------------------------------------------------------------');
% % % disp('            trial                   |                         FES                         |                       Catch                         ');
% % % disp('------------------------------------------------------------------------------------------------------------------------------------------------');
% % % disp('                      | duration(m) |    reward    failure    abort    incomp    rate(%)  |  reward    failure    abort    incomp    rate(%)    ');
% % % disp('------------------------------------------------------------------------------------------------------------------------------------------------');
% % % clf;
% 
% 
% %add average rate axis
% axis([-5,t_end+5,-5,105]);
% legend('successful FES rate','successful catch rate',2,'Location','SouthWestOutside');
% axes('position',[.08,.25,.3,.65]);
% barM=[sum(matrix(:,1))/(i-1) sum(matrix(:,2))/(i-1)]';
% bar(barM);
% text(0.6,sum(matrix(:,1))/(i-1)+3,num2str(sum(matrix(:,1)/(i-1))));
% text(1.7,sum(matrix(:,2))/(i-1)+3,num2str(sum(matrix(:,2)/(i-1))));
% 
% title('average rate');
% ylabel('%');
% ylim([0 100]);

