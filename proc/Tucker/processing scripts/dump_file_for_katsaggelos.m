function [figure_list,data_struct]=dump_file_for_katsaggelos(fpath,input_data)
figure_list=[];
data_struct=[];

temppath=follow_links([fpath, input_data.filename]);
ftype=temppath(end-3:end);
switch (ftype)
    case '.plx'
        bdf=get_plexon_data(temppath,input_data.labnum,'verbose','noeye');
    case '.nev'
        [filepath,fileprefix,~] = fileparts(temppath);
        if ~strcmp(filepath(end),filesep)
            filepath(end+1) = filesep;
        end
        NEVNSx = cerebus2NEVNSx(filepath,fileprefix);
        %check whether force fileds are properly labeled and label them if
        %they are not
        
        bdf=get_nev_mat_data(NEVNSx,'verbose','noeye', input_data.labnum);
    case '.mat'
        load(temppath)
        if exist('NEVNSx','var')
            bdf=get_nev_mat_data(NEVNSx,'verbose','noeye', input_data.labnum);
        elseif exists('bdf','var')
            %hooray, we already have a bdf
        else
            error('dump_file_for_katsaggelos:BadMatFile',['did not find a NEVNSX or bdf structure in: ', temppath])
        end
    otherwise
        error('dump_file_for_katsaggelos:InvalidFileType',['dump_file_for_katsaggelos does not recognize the extension: ',ftype])
end
optionstruct.compute_pos_pds=0;
optionstruct.compute_vel_pds=0;
optionstruct.compute_acc_pds=0;
optionstruct.compute_force_pds=0;
optionstruct.compute_dfdt_pds=0;
optionstruct.compute_dfdtdt_pds=0;
optionstruct.data_offset=0.015;%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset

opts.do_firing_rate=1;
opts.do_trial_table=0;
bdf=postprocess_bdf(bdf,opts);
if ispc
    [~,hostname]=system('hostname');
    hostname=strtrim(hostname);
    username=strtrim(getenv('UserName'));
else
    hostname=[];
    username=[];
end
bdf.meta.processed_with={'posprocess_bdf','date','computer name','user name'};

which_units=unit_list(bdf,0);
%behaviors = parse_for_tuning(bdf,'continuous','opts',optionstruct,'units',which_units);
%duplicate and shift unit count data

%look at pds:
%%%%%%%%%%%%%%%
%% prep bdf
    if isfield(input_data,'task')
        bdf.meta.task=input_data.task;
    else
        bdf.meta.task = 'RW';
    end
    
    %add firing rate to the units fields of the bdf
    if isfield(input_data,'offset')
        opts.offset=input_data.offset;
    else
        %opts.offset=-.015;
        opts.offset=0;
    end
    if isfield(input_data,'binsize')
        opts.binsize=input_data.binsize;
    else
        opts.binsize=0.05;
    end
    opts.do_trial_table=0;
    opts.do_firing_rate=1;
    bdf=postprocess_bdf(bdf,opts);
    
    make_session_summary
    data_struct.session_summary=session_summary;
%% set up parse for tuning
    if isfield(input_data,'pos_pd')
        optionstruct.compute_pos_pds=input_data.pos_pd;
    else
        optionstruct.compute_pos_pds=0;
    end
    
    if isfield(input_data,'vel_pd')
        optionstruct.compute_vel_pds=input_data.vel_pd;
    else
        optionstruct.compute_vel_pds=1;
    end
    
    if isfield(input_data,'acc_pd')
        optionstruct.compute_acc_pds=input_data.acc_pd;
    else
        optionstruct.compute_acc_pds=0;
    end
    
    if isfield(input_data,'force_pd')
        optionstruct.compute_force_pds=input_data.force_pd;
    else
        optionstruct.compute_force_pds=0;
    end
    
    if isfield(input_data,'dfdt_pd')
        optionstruct.compute_dfdt_pds=input_data.dfdt_pd;
    else
        optionstruct.compute_dfdt_pds=0;
    end
    
    if isfield(input_data,'dfdtdt_pd')
        optionstruct.compute_dfdtdt_pds=input_data.dfdtdt_pd;
    else
        optionstruct.compute_dfdtdt_pds=0;
    end
    
    if isfield(input_data,'offset')%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset
        optionstruct.data_offset=input_data.offset;
    else
        optionstruct.data_offset=-.015;%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset
    end
    
    which_units=1:length(bdf.units);
    clear temp
    if isfield(input_data, 'only_sorted')
        if input_data.only_sorted
            for i=1:length(bdf.units)
                temp(i)=~(bdf.units(i).id(2)==0 | bdf.units(i).id(2)==255);
            end
            which_units=which_units(logical(temp));
        end
    end
%% parse data and get GLM tuning
    disp('parsing data for PD tuning analysis')
    data_struct.unit_behaviors = parse_for_tuning(bdf,'continuous','opts',optionstruct,'units',which_units);
    
%  %build pos-vel-force GLM model
%     disp('building GLM model for PDs')
%     data_struct.unit_tuning_stats = compute_tuning(data_struct.unit_behaviors,[1 1 0 1 0 0 0],struct('num_rep',100),'poisson');
%         
    
%% add lags to FR and compile data for weiner filter    
    %duplicate and shift unit data to include lags
    numlags=10;
    FR=data_struct.unit_behaviors.FR;
    numunits=size(FR,2);
    FR_withlags=-1*ones(size(FR,1)+numlags-1,numunits*numlags);
    base_unit_ids=data_struct.unit_behaviors.unit_ids;
    data_struct.unit_behaviors.unit_ids= -1*ones(size(base_unit_ids,1)*numlags,2);
    %base_units=data_struct.unit_behaviors.which_units;
    %data_struct.unit_behaviors.which_units=-1*ones(size(base_units,1)*numlags,1);
    for i=1:numlags
        rowstart=1+numlags-i;
        rowend=rowstart+size(FR,1)-1;
        colstart=1+(i-1)*numunits;
        colend=colstart+numunits-1;
        FR_withlags(rowstart:rowend,colstart:colend)=FR;
        %add unit ids for the lags
        data_struct.unit_behaviors.unit_ids(colstart:colend,:)=base_unit_ids;
        
    end
    
    %trim ends of FR_withlags
    FR=FR_withlags(numlags:end-numlags,:);
    T=data_struct.unit_behaviors.T(1:end-numlags);
    %trim ends of kinematic data
    for i=1:length(data_struct.unit_behaviors.armdata)
        armdata(i).data=data_struct.unit_behaviors.armdata(i).data(1:end-numlags,:);
    end

    disp('constructing dataset for weiner filter')
    data_struct.session_data.meta=bdf.meta;
    if isfield(bdf,'force')
        data_struct.session_data.data=dataset({armdata(1).data(),'position'},{armdata(2).data,'velocity'},{armdata(4).data,'force'},{FR,'spikes'});
    else
        data_struct.session_data.data=dataset({armdata(1).data(),'position'},{armdata(2).data,'velocity'},{FR,'spikes'});
    end
    data_struct.session_data.raw.units=bdf.units;
    data_struct.session_data.raw.pos=bdf.pos;
    data_struct.session_data.raw.vel=bdf.vel;
    if isfield(bdf,'force')
        data_struct.session_data.raw.force=bdf.force;
    end

%% run static weiner model on dataset
    %    USAGE:   [H,vaf,mcc]=filMIMO(X,Y,numlags,numsides,fs);
    %    X        : Columnwise inputs  [x1 x2 ...] to the unknown system
    %    Y        : Columnwise outputs [y1 y2 ...] to the unknown system
    %    numlags  : the number of lags to calculate for all linear filters 0
    %    used here since lags are computed explicitly above
    %    numsides : determine a causal (1 side) or noncausal 
    %               (2 sides) response.
    %    fs		: Sampling rate (default=1)
    %    H      : the identified nonparametric filters between X and Y.
    %
    % The returned filter matrix is organized in columns as:
    %     H=[h11 h21 h31 ....;
    %        h12 h22 h32 ....;
    %        h13 h23 h33 ...;
    %        ... ... ... ...]
    %  Which represents the system:
    %  y1=h11 + h12*x1 + h13*x2 + h14*x3 + ...     
    %  y2=h21 + h22*x1 + h23*x2 + h24*x3 + ...     
    %  y3=h31 + h32*x1 + h33*x2 + h34*x3 + ...    
    %  ... 
    sep_point=floor(size(data_struct.session_data.data.position,1)/2);
    
    if isfield(bdf,'force')
        Y=[data_struct.session_data.data.position,data_struct.session_data.data.velocity,data_struct.session_data.data.force];
    else
        Y=[data_struct.session_data.data.position,data_struct.session_data.data.velocity];
    end
    X=data_struct.session_data.data.spikes(:,1:numunits);
    fs=1;
    numsides=1;%lags are computed explicitly above
    %create filter
    disp('fitting static filter on first 1/2 of the data')
    data_struct.static_weiner.X_base=X(1:sep_point,:);
    data_struct.static_weiner.Y_base=Y(1:sep_point,:);
    
    [data_struct.static_weiner.H,data_struct.static_weiner.v,data_struct.static_weiner.mcc]=filMIMO4(data_struct.static_weiner.X_base,data_struct.static_weiner.Y_base,1,numsides,fs);
    %test filter
    disp('estimating kinematic parameters from neural spiking for the second half of the data')
    data_struct.static_weiner.validate.X_act=X(sep_point+1:end,:);
    [data_struct.static_weiner.validate.Y_fit]=predMIMO4(data_struct.static_weiner.validate.X_act,data_struct.static_weiner.H,numsides,fs,0);
    data_struct.static_weiner.validate.Y_act=Y(sep_point+1:end,:);
    for i=1:6
        data_struct.static_weiner.validate.VAF(i)=1-var(data_struct.static_weiner.validate.Y_act(:,i)-data_struct.static_weiner.validate.Y_fit(:,i))/var(data_struct.static_weiner.validate.Y_act(:,i));
    end
    figure_list(length(figure_list)+1)=figure;
    plot(data_struct.static_weiner.validate.Y_fit(:,3),data_struct.static_weiner.validate.Y_act(:,3));
    title('x velocity, predicted vs actual, static weiner')
    figure_list(length(figure_list)+1)=figure;
    plot(data_struct.static_weiner.validate.Y_fit(:,4),data_struct.static_weiner.validate.Y_act(:,4));
    title('y velocity, predicted vs actual, static weiner')
%% re-run weiner filter with all the neural lags:
    disp('fitting dynamic filter on first half of the data')
    data_struct.dynamic_weiner.X_base=data_struct.session_data.data.spikes(1:sep_point,:);
    data_struct.dynamic_weiner.Y_base=Y(1:sep_point,:);
    
    [data_struct.dynamic_weiner.H,data_struct.dynamic_weiner.v,data_struct.dynamic_weiner.mcc]=filMIMO4(data_struct.dynamic_weiner.X_base,data_struct.dynamic_weiner.Y_base,1,numsides,fs);
    disp('estimating kinematic parameters from neural spiking for the second half of the data');
    data_struct.dynamic_weiner.validate.X_act=X(sep_point+1:end,:);
    [data_struct.dynamic_weiner.validate.Y_fit]=predMIMO4(data_struct.dynamic_weiner.validate.X_act,data_struct.dynamic_weiner.H,numsides,fs,0);
    data_struct.dynamic_weiner.validate.Y_act=Y(sep_point+1:end,:);
    for i=1:6
        data_struct.dynamic_weiner.validate.VAF(i)=1-var(data_struct.dynamic_weiner.validate.Y_act(:,i)-data_struct.dynamic_weiner.validate.Y_fit(:,i))/var(data_struct.dynamic_weiner.validate.Y_act(:,i));
    end
    figure_list(length(figure_list)+1)=figure;
    plot(data_struct.dynamic_weiner.validate.Y_fit(:,3),data_struct.dynamic_weiner.validate.Y_act(:,3));
    title('x velocity, predicted vs actual, Dynamic weiner')
    figure_list(length(figure_list)+1)=figure;
    plot(data_struct.dynamic_weiner.validate.Y_fit(:,4),data_struct.dynamic_weiner.validate.Y_act(:,4));
    title('y velocity, predicted vs actual, Dynamic weiner')
    
%% put bdf into data_struct and clear it
    data_struct.bdf=bdf;
    clear bdf
