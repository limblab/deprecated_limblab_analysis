function pds=get_pd_table(tuning_data,varargin)
    %gets a matrix of velocity PDs from the full tuning matrix returned by
    %compute_tuning. Each row will be of the format: 
    %[channel unit PD CI_low CI_high Modulation Modulation_low Modulation_high]
    
    %first figure out which column of the tuning data we need and store in
    %variable i
    if ~isempty(varargin)
        pd_type=varargin{1};
    else
        pd_type='vel';
    end
    
    for i=1:size(tuning_data,2)
        if strcmp(tuning_data(1,i).name,pd_type)
            break
        end
    end
    chan_unit=zeros(size(tuning_data,1),2);
    dir=zeros(size(tuning_data,1),1);
    dir_CI=zeros(size(tuning_data,1),2);
    moddepth=zeros(size(tuning_data,1),1);
    moddepth_CI=zeros(size(tuning_data,1),2);
    
    for j=1:size(tuning_data,1)
        chan_unit(j,:)=tuning_data(j,i).unit_id;
        dir(j)=tuning_data(j,i).PD.dir;
        dir_CI(j,:)=tuning_data(j,i).PD.dir_CI;
        moddepth(j)=tuning_data(j,i).PD.moddepth;
        moddepth_CI(j,:)=tuning_data(j,i).PD.moddepth_CI;
    end
    pds=dataset({chan_unit(:,1),'channel'},{chan_unit(:,2),'unit'},{dir,'dir'},{dir_CI,'dir_CI'},{moddepth,'moddepth'},{moddepth_CI,'moddepth_CI'});
    pds=sortrows(pds,3);
end