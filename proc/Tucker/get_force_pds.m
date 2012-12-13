%%set params
    ts = 50;%binning size
    offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

%%load data
    fname='C:\Users\limblab\Desktop\dail_data\11092012\bumpchoice\Kramer_bumpchoice_11092012_tucker_8ch_stim_001-01.nev';
    disp(strcat('converting: ',fname))
    bdf=get_cerebus_data(fname,3,'verbose','noeye');
    save(fname,'bdf')
    %disp(strcat('loading: ',fname))
    %load('C:\Users\limblab\Desktop\dail_data\11092012\bumpchoice\Kramer_bumpchoice_11092012_tucker_8ch_stim_001-01.mat')

%%identify time vector for binning
    vt = bdf.vel(:,1);
    t = vt(1):ts/1000:vt(end);

%%convert bdf to tdf
    disp('Adding trial table to bdf structure')
    if ~isfield(bdf,'tt')
        [bdf.tt,bdf.tt_hdr]=bc_trial_table4(bdf);
    end
    disp('Adding firing rate information to bdf.units')
    if isfield(bdf,'units')
        if ~isfield(bdf.units(1),'fr')
            for i=1:length(bdf.units)
                if isempty(bdf.units(i).id)
                    %bdf.units(unit).id=[];
                else
                    spike_times = bdf.units(i).ts+ offset;%the offset here will effectively align the firing rate to the kinematic data
                    spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
                    bdf.units(i).fr = [t;train2bins(spike_times, t)]';
                end
            end
        end
    end
%%get non-stim bump segments of data
    disp('converting force from load cell to commanded values')
    bdf.force=convert_bump_mag(bdf);
    disp('Removing non-bump segments from the trial')
    clear timestamps
    timestamps(:,1)=bdf.tt(:,bdf.tt_hdr.bump_time);
    timestamps(:,2)=timestamps(:,1)+bdf.tt(:,bdf.tt_hdr.bump_dur)+2*bdf.tt(:,bdf.tt_hdr.bump_ramp);
    timestamps=timestamps(bdf.tt(:,bdf.tt_hdr.stim_trial)==0,:);%exclude stim trials
    sub_bdf=get_sub_trials(bdf,timestamps);
%%get force based PD
    disp('computing PDs and plotting results')
    PD_force_plot(sub_bdf,'Kramer',2,1)