function varargout = mg_fes_exp(varargin)

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
        
        tt = mg_trial_table(bdf);

        fes_rew    = sum(tt(:,4)==0 & tt(:,12)==double('R'));
        fes_abort  = sum(tt(:,4)==0 & tt(:,12)==double('A'));
        fes_fail   = sum(tt(:,4)==0 & tt(:,12)==double('F'));
        fes_incomp = sum(tt(:,4)==0 & tt(:,12)==double('I'));
        total_fes  = fes_rew+fes_fail;
        catch_rew    = sum(tt(:,4)==1 & tt(:,12)==double('R'));
        catch_abort  = sum(tt(:,4)==1 & tt(:,12)==double('A'));
        catch_fail   = sum(tt(:,4)==1 & tt(:,12)==double('F'));
        catch_incomp = sum(tt(:,4)==1 & tt(:,12)==double('I'));    
        total_catch  = catch_rew+catch_fail;
        
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
