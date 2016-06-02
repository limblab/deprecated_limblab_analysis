function [figure_list,data_struct]=BumpDirection_PDs(folderpath,input_data)
    %function that computes bump an dmove PDs from a CObump file
    %formatted to be called from run_data_processing
    %operates on a single data file in the folder specified by folderpath.
    %(will follow a shortcut if the file itself isn't in the folder)
    
    disp('converting nev files to bdf format')
    file_list=autoconvert_nev_to_bdf(folderpath,input_data.matchstring,input_data.labnum);
    data_struct.file_list=file_list;
    disp('concatenating bdfs into single structure')
    bdf=concatenate_bdfs_from_folder(folderpath,input_data.matchstring,0,0,0);

    %% get trial table for the aggregate data
        [bdf.TT,bdf.TT_hdr]=bc_trial_table4(bdf);
        ts = 50;
        offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

        if isfield(bdf,'units')
            vt = bdf.vel(:,1);
            t = vt(1):ts/1000:vt(end);

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

        data_struct.Aggregate_bdf=bdf;

    %% remove unit sorting from bdf
        bdf_multiunit=remove_sorting(bdf);
        data_struct.Multiunit_Aggregate_bdf=bdf_multiunit;
    
    %% find bump periods
        bump_onset=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.bump_time);
        bump_delay=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.bump_delay);
        bump_hold=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.bump_dur);
        mask=bump_onset>1;
        bump_onset=bump_onset(mask);
        bump_delay=bump_delay(mask);
        bump_hold=bump_hold(mask);
        timestamps=[(bump_onset+bump_delay) , (bump_onset+bump_delay+bump_hold)];
        
    % make sub_bdf for bump periods
        bdf_bump=get_sub_bdf(bdf,timestamps);
        data_struct.bump_bdf=bdf_bump;
        
    %% find move periods
        cue_times=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.go_cue);
        end_times=bdf_multiunit.TT(:,bdf_multiunit.TT_hdr.end_time);
        mask=cue_times>1;
        cue_times=cue_times(mask);
        end_times=end_times(mask);
        timestamps=[cue_times,end_times];

    % make sub_bdf for move periods
        bdf_move=get_sub_bdf(bdf,timestamps);
        data_struct.move_bdf=bdf_move;
    %% compute all bump PDs
        % get pds, standard errors and modulation depth and unit list
        model='posvel';
        %[pds, errs, moddepth] = glm_pds(bdf,include_unsorted,model);
        [pds, errs, moddepth,CI,LL, LLN]=glm_pds_TT(bdf_bump,2,model,1000,10000);
        u1 = unit_list(bdf_bump,1); % gets two columns back, first with channel
        % numbers, second with unit sort code on that channel
        if isempty(u1)
            error('S1_ANALYSIS:PROC:TUCKER:PDS:PD_PLOT:NoUnits','no units were found to compute PDs on')
        end
        if (include_unsorted && length(u1)~=length(moddepth))
            disp('discarding clusters')
            u1=u1(~u1(:,2),:);
        end
        %set_outputs
        data_struct.bump_PDs_posvel=[double(u1(:,1)),pds,moddepth,CI];
        
        % generate histograms of PD data
        % plot confidence interval histograms
        h_bump_PD_CI_hist=figure('Name','bump_PD_CI_hist'); 
        temp=~isnan(CI(:,1));
        hist(abs((CI(temp,2)-CI(temp,1))*180/pi),[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
        xlim([0,360])
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of 95% confidence interval on bump PDs')
        figure_list(1)=h_bump_PD_CI_hist;
        
        % plot PD histograms
        h_bump_PD_ang_hist=figure('Name','bump_PD_angle_hist');
        hist(pds(~isnan(pds))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of bump PDs')
        figure_list(2)=h_bump_PD_ang_hist;
        
        % plot modulation depth histogram
        h_bump_PD_mags_hist=figure('Name','bump_PD_mags_hist');
        hist(moddepth(~isnan(moddepth)),30) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
        xlabel('sqrt(a^2+b^2) where a and b are the GLM weights on x and y velocity')
        ylabel('PD counts')
        title('Histogram of bump PD modulation depth')
        figure_list(3)=h_bump_PD_mags_hist;
        
    %% compute all move PDs
        % get pds, standard errors and modulation depth and unit list
        model='posvel';
        %[pds, errs, moddepth] = glm_pds(bdf,include_unsorted,model);
        [pds, errs, moddepth,CI,LL, LLN]=glm_pds_TT(bdf_move,2,model,1000,10000);
        u1 = unit_list(bdf_move,1); % gets two columns back, first with channel
        % numbers, second with unit sort code on that channel
        if isempty(u1)
            error('S1_ANALYSIS:PROC:TUCKER:PDS:PD_PLOT:NoUnits','no units were found to compute PDs on')
        end
        if (include_unsorted && length(u1)~=length(moddepth))
            disp('discarding clusters')
            u1=u1(~u1(:,2),:);
        end
        %set_outputs
        data_struct.move_PDs_posvel=[double(u1(:,1)),pds,moddepth,CI];
        % generate histograms of PD data
        % plot confidence interval histograms
        h_move_PD_CI_hist=figure('Name','move_PD_CI_hist'); 
        temp=~isnan(CI(:,1));
        hist(abs((CI(temp,2)-CI(temp,1))*180/pi),[5:10:360]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
        xlim([0,360])
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of 95% confidence interval on move PDs')
        figure_list(4)=h_move_PD_CI_hist;
        
        % plot PD histograms
        h_move_PD_ang_hist=figure('Name','move_PD_angle_hist');
        hist(pds(~isnan(pds))*180/pi,[-175:20:180]) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
        xlabel('degrees')
        ylabel('PD counts')
        title('Histogram of move PDs')
        figure_list(5)=h_move_PD_ang_hist;
        
        % plot modulation depth histogram
        h_move_PD_mags_hist=figure('Name','move_PD_mags_hist');
        hist(moddepth(~isnan(moddepth)),30) % channels that have been deselected or eliminated in another way have NaN as PD, CI's and moddepths
        xlabel('sqrt(a^2+b^2) where a and b are the GLM weights on x and y velocity')
        ylabel('PD counts')
        title('Histogram of move PD modulation depth')
        figure_list(6)=h_move_PD_mags_hist;
        
    %% compute differences in PD between move and bump conditions
        PD_diff=data_struct.bump_PDs_posvel(:,2)-data_struct.move_PDs_posvel(:,2);
        mag_diff=data_struct.bump_PDs_posvel(:,3)-data_struct.move_PDs_posvel(:,3);
        CI_diff=data_struct.bump_PDs_posvel(:,4)-data_struct.move_PDs_posvel(:,4);
        % plot histograms for difference data
        h_PD_diff=figure('Name','PD_difference_hist');
        mask=~isnan(PD_diff);
        hist(PD_diff(mask));
        title('Histogram of changes in PD (bump_PD - move_PD)')
        xlabel('change in PD')
        ylabel('count of units')
        figure_list(7)=h_PD_diff;
        
        h_PD_mag_diff=figure('Name','PD_magnitude_difference_hist');
        mask=~isnan(mag_diff);
        hist(mag_diff(mask));
        title('Histogram of changes in PD magnitude  (bump_PD_mag - move_PD_mag)')
        xlabel('change in magnitude')
        ylabel('count of units')
        figure_list(8)=h_PD_mag_diff;
        
        h_PD_CI_diff=figure('Name','PD_CI_difference_hist');
        mask=~isnan(CI_diff);
        hist(CI_diff(mask));
        title('Histogram of changes in CI (bump_PD_CI - move_PD_CI)')
        xlabel('change in CI')
        ylabel('count of units')
        figure_list(9)=h_PD_CI_diff;

end