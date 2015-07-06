function [figure_list,data_struct]=move_PDs(folderpath,input_data)
    figure_list=[];
%%set params
    ts = 50;%binning size
    offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

    %load data
    %check to see if a bdf already exists:
    folderlist=dir(strcat(folderpath,'\Output_data'));
    fnames={folderlist.name};
    if ~isempty(strmatch( 'bdf.mat',fnames))
        temp=load(strcat( folderpath,'\Output_data\bdf.mat'));
        bdf=temp.temp;
    else
        fname=follow_links([folderpath,input_data.filename]);
        disp(strcat('converting: ',fname))
        bdf=get_cerebus_data(fname,3,'verbose','noeye');
    end
    
    bdf_multiunit=remove_sorting(bdf); 
    temp=[];
    %get units structure with no unsorted or invalidated spikes
    for i=1:length(bdf.units)
        if (bdf.units(1,i).id(2)==0 | bdf.units(1,i).id(2)==255)
            continue
        else
            temp(1,length(temp)+1).id=bdf.units(1,i).id;
            temp(1,length(temp)).ts=bdf.units(1,i).ts;
        end
    end
    bdf.units=temp;

%   add firing rate to bdf.units so it isn't recomputed during bootstrapping   
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
    bdf=testAllTuning(bdf);
    data_struct.bdf=bdf;  
    %compute PDs for single units
    disp('computing single unit PDs and plotting results')
    %[pds, errs, moddepth] = glm_pds(bdf,include_unsorted,model);
    [pds, errs, moddepth,CI]=glm_pds_TT2(bdf,0,'posvel',1000,10000);
    u1 = unit_list(bdf,1); % gets two columns back, first with channel
    % numbers, second with unit sort code on that channel
    if isempty(u1)
        error('move_PDS:NoUnits','no units were found to compute PDs on')
    end
    %set_outputs
    data_struct.PD_data=[double(u1),[bdf.units(:).tuned]',pds,moddepth,CI];
%% now do the multiunit
    %   add firing rate to bdf.units so it isn't recomputed during bootstrapping   
    if isfield(bdf_multiunit,'units')
        vt = bdf_multiunit.vel(:,1);
        t = vt(1):ts/1000:vt(end);

        for i=1:length(bdf_multiunit.units)
            if isempty(bdf_multiunit.units(i).id)
                %bdf.units(unit).id=[];
            else
                spike_times = bdf_multiunit.units(i).ts+ offset;%the offset here will effectively align the firing rate to the kinematic data
                spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
                bdf_multiunit.units(i).fr = [t;train2bins(spike_times, t)]';
            end
        end
    end
    bdf_multiunit=testAllTuning(bdf_multiunit);
    data_struct.bdf_multiunit=bdf_multiunit;  
    %compute PDs for single units
    disp('computing single unit PDs and plotting results')
    %[pds, errs, moddepth] = glm_pds(bdf,include_unsorted,model);
    [pds, errs, moddepth,CI]=glm_pds_TT2(bdf_multiunit,2,'posvel',1000,10000);
    u1 = unit_list(bdf,1); % gets two columns back, first with channel
    % numbers, second with unit sort code on that channel
    if isempty(u1)
        error('move_PDS:NoUnits','no units were found to compute PDs on')
    end
    %set_outputs
    data_struct.PD_data=[double(u1),[bdf_multiunit.units(:).tuned]',pds,moddepth,CI];

end
    
