%script to test parse for tuning:
%% load up test data set
%load('Z:\MrT_9I4\Processed\experiment_20141119_RW\Output_Data\Multi_unit_bdf.mat')
% bdf=Multi_unit_bdf;
% clear Multi_unit_bdf
bdf=get_cerebus_data( 'Z:\Kramer_10I1\Kramer\RAW\Kramer_RW_neural_001.nev',3,'verbose','noeye');
bdf.meta.task='RW';
ts = 50;
offset=0; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

if isfield(bdf,'units')
    vt = bdf.pos(:,1);
    t = vt(1):ts/1000:vt(end);
    for i=1:length(bdf.units)
        if isempty(bdf.units(i).id)
            %bdf.units(unit).id=[];
        else
            spike_times = bdf.units(i).ts+ offset;%the offset here will effectively align the firing rate to the kinematic data
            spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
            bdf.units(i).FR = [t;train2bins(spike_times, t)]';
        end
    end
end
[bdf.TT,bdf.TT_hdr]=rw_trial_table(bdf);
%% 'continuous'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'continuous');

%viable method_opts for the continuous method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'continuous','opts',optionstruct,'units',which_units);
%% 'peak speed'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'peak speed');
%viable method_opts for the peak vel method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset
%   -data_window

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;
optionstruct.data_window=0.400;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'peak speed','opts',optionstruct,'units',which_units);
%% 'peak force'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'peak force');
%viable method_opts for the peak dt method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset
%   -data_window

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;
optionstruct.data_window=0.400;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'peak force','opts',optionstruct,'units',which_units);
%% 'peak dfdt'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'peak dfdt');
%viable method_opts for the peak dfdt method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset
%   -data_window

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;
optionstruct.data_window=0.400;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'peak dfdt','opts',optionstruct,'units',which_units);
%% 'peak acceleration'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'peak acceleration');
%viable method_opts for the peak acc method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset
%   -data_window

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;
optionstruct.data_window=0.400;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'peak acceleration','opts',optionstruct,'units',which_units);
%% 'peak dfdtdt'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'peak dfdtdt');
%viable method_opts for the peak dfdtdt method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset
%   -data_window

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;
optionstruct.data_window=0.400;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'peak dfdtdt','opts',optionstruct,'units',which_units);
%% 'target onset'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'target onset');
%viable method_opts for the target onset method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset
%   -data_window

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;
optionstruct.data_window=0.400;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'target onset','opts',optionstruct,'units',which_units);
%% 'go cues'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'go cues');
%viable method_opts for the target onset method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset
%   -data_window

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;
optionstruct.data_window=0.400;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'go cues','opts',optionstruct,'units',which_units);
%% 'trials'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'trials');
%viable method_opts for the trials method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'trials','opts',optionstruct,'units',which_units);
%% 'bumps'
clear temp_defaults
clear temp_opts
clear optionstruct
temp_defaults=parse_for_tuning(bdf,'bumps');
%viable method_opts for the bumps method:
%   -lags
%   -comptute_pos_pds
%   -comptute_vel_pds
%   -comptute_acc_pds
%   -comptute_force_pds
%   -comptute_dfdt_pds
%   -comptute_dfdtdt_pds
%   -data_offset

optionstruct.lags=[.050 .100 .150];
optionstruct.compute_pos_pds=1;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=1;
optionstruct.compute_force_pds=1;
optionstruct.compute_dfdt_pds=1;
optionstruct.compute_dfdtdt_pds=1;
optionstruct.data_offset=.010;

which_units=[3 5 20 30 31];

temp_opts=parse_for_tuning(bdf,'bumps','opts',optionstruct,'units',which_units);
%% test output for sanity
% test default:
disp('Testing defaults')
is_problem=0;
[R,C]=size(temp_defaults.FR);
[Rp,Cp]=size(bdf.pos);
if C~=length(bdf.units)
    disp('incorrectNumber of units in output of default')
    is_problem=1;
end
if length(temp_defaults.FR)~=length(temp_defaults.T)
    disp('time vector, does not match FR matrix for defaults')
    is_problem=1;
end
if length(temp_defaults.which_units)~=length(bdf.units)
    disp('list of units does not match bdf.units')
    is_problem=1;
end
if length(temp_defaults.armdata)~=6;
    disp('wrong number of cells in armdata')
    is_problem=1;
end

for i=1:6
    [Ra,Ca]=size(temp_defaults.armdata{1,i}.data);
    if Ra~=R
        disp(strcat('temp_defaults.armdata{1,',num2str(i),'}.data has a different number of rows than temp_defaults.FR'))
        is_problem=1;
    end
    if Ca~=2
        disp(strcat('temp_defaults.armdata{1,',num2str(i),'}.data has the wrong number of columns'))
        is_problem=1;
    end
    if temp_defaults.armdata{1,i}.num_lags~=0
        disp(strcat('incorrect number of lags in temp_defaults.armdata{1,',num2str(i),'}.num_lags'))
        is_problem=1;
    end
    if temp_defaults.armdata{1,i}.num_base_cols~=Cp-1;
        disp(strcat('incorrect number of base columns in temp_defaults.armdata{1,',num2str(i),'}.num_base_cols'))
        is_problem=1;
    end
    if i==2
        if temp_defaults.armdata{1,i}.doPD~=1
            disp('temp_defaults.armdata{1,2}.doPD is not set to 1')
            is_problem=1;
        end
    else
        if temp_defaults.armdata{1,i}.doPD~=0
            disp(strcat('temp_defaults.armdata{1,',num2str(i),'}.doPD is not set to 0') )
            is_problem=1;
        end
    end
end

if is_problem~=1;
    disp('No problems with defaults')
    is_problem=0;
end
% test options:
disp('Testing options')
[R,C]=size(temp_opts.FR);
if C~=length(which_units)
    disp('incorrectNumber of units in output of default')
    is_problem=1;
end
if temp_opts.which_units~=which_units
    disp('Which units vector is not correct')
    is_problem=1;
end
if length(temp_opts.FR)~=length(temp_opts.T)
    disp('time vector, does not match FR matrix for opts')
    is_problem=1;
end
if length(temp_opts.armdata)~=6;
    disp('wrong number of cells in armdata')
    is_problem=1;
end

for i=1:6
    [Ra,Ca]=size(temp_opts.armdata{1,i}.data);
    
    if Ra~=R
        disp(strcat('temp_opts.armdata{1,',num2str(i),'}.data has a different number of rows than temp_defaults.FR'))
        is_problem=1;
    end
    if Ca~=(Cp-1)*(length(optionstruct.lags)+1)
        disp(strcat('temp_opts.armdata{1,',num2str(i),'}.data has the wrong number of columns'))
        is_problem=1;
    end
    if temp_opts.armdata{1,i}.num_lags~=length(optionstruct.lags)
        disp(strcat('incorrect number of lags in temp_opts.armdata{1,',num2str(i),'}.num_lags'))
        is_problem=1;
    end
    if temp_opts.armdata{1,i}.num_base_cols~=(Cp-1)*(length(optionstruct.lags)+1)
        disp(strcat('incorrect number of base columns in temp_opts.armdata{1,',num2str(i),'}.num_base_cols'))
        is_problem=1;
    end
    if i==2
        if temp_opts.armdata{1,i}.doPD~=0
            disp('temp_defaults.opts{1,2}.doPD is not set to 1')
            is_problem=1;
        end
    else
        if temp_opts.armdata{1,i}.doPD~=1
            disp(strcat('temp_opts.armdata{1,',num2str(i),'}.doPD is not set to 0') )
            is_problem=1;
        end
    end
end
if is_problem~=1;
    disp('No problems with defaults')
    is_problem=0;
end

%plot lags to see if they look right
for i=1:6
    figure
    plot(temp_opts.T(1:100),temp_opts.armdata{1,i}.data(1:100,1),'k')
    title(strcat('x ',temp_opts.armdata{1,i}.name,' vs index'))
    hold on
    plot(temp_opts.T(1:100),temp_opts.armdata{1,i}.data(1:100,3),'b')
    plot(temp_opts.T(1:100),temp_opts.armdata{1,i}.data(1:100,5),'r')
    plot(temp_opts.T(1:100),temp_opts.armdata{1,i}.data(1:100,7),'g')
    legend('no lag','lag1','lag2','lag3')

    hold off
end