%% get nevnsx structure
    basepath='E:\processing\post_DARPA\force PD\';
    fname='Kramer_BC_06132013_tucker_no_stim_001.nev';
    savename='Kramer_BC_06132013_tucker_no_stim_001_bumponly.nev';
    %filepath='E:\processing\Kevin_data\Kevin_2013-06-07_UF_005.nev';
    NEVNSx=load_NEVNSX_object(strcat(basepath,fname));

%% convert to bdf
    bdf=get_nev_mat_data(NEVNSx);

%% get the trial table
    make_tdf

%% extract timestamps of interest from the bdf
    mask=bdf.tt(:,bdf.tt_hdr.bump_mag)>0 & bdf.tt(:,bdf.tt_hdr.stim_trial)==0 & bdf.tt(:,bdf.tt_hdr.trial_result)~=1;
    timestamps=[];
    timestamps(:,1)=bdf.tt(  mask,  bdf.tt_hdr.bump_time);
    timestamps(:,2)=bdf.tt(  mask,  bdf.tt_hdr.bump_time)  +  bdf.tt(  mask,  bdf.tt_hdr.bump_ramp)  +  bdf.tt(  mask,  bdf.tt_hdr.bump_ramp);
    %convert bdf timestamps into int32 time used in NEV object
    timestamps=round(timestamps*30000);

%% prune the nevnsx.nev data based on the timestamps
    mask=[];
    for i=1:length(timestamps)
        temp_mask=find(NEVNSx.NEV.Data.Spikes.TimeStamp>timestamps(i,1) & NEVNSx.NEV.Data.Spikes.TimeStamp<timestamps(i,2));
        mask=[mask temp_mask];
    end

    NEVNSx.NEV.Data.Spikes.TimeStamp=NEVNSx.NEV.Data.Spikes.TimeStamp(:,mask);
    NEVNSx.NEV.Data.Spikes.Electrode=NEVNSx.NEV.Data.Spikes.Electrode(:,mask);
    NEVNSx.NEV.Data.Spikes.Unit=NEVNSx.NEV.Data.Spikes.Unit(:,mask);
    NEVNSx.NEV.Data.Spikes.Waveform=NEVNSx.NEV.Data.Spikes.Waveform(:,mask);

%% remove cross channel artifacts
    NEVNSx.NEV=artifact_removal(NEVNSx.NEV,10,0.001);


%% save bdf and pruned NEV
    saveNEVOnlySpikes(NEVNSx.NEV,basepath,savename)
    save( strcat(basepath, fname(1:(length(fname)-3)), 'mat'), 'bdf','-v7.3')
    
