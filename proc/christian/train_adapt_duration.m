function [vaf,R2,preds,decoders,figh] = train_adapt_duration(train_data,test_data,train_duration,type,varargin)

if any(train_duration > train_data.timeframe(end)-train_data.timeframe(1)+1)
    error('training time exceed duration of data');
end

if nargin>4 params = varargin{1}; end
num_iter = length(train_duration);

[num_pts,num_out]  = size(test_data.cursorposbin);
% [num_pts,num_out]  = size(test_data.emgdatabin);

vaf      = nan(num_iter,num_out);
R2       = nan(num_iter,num_out);
preds    = nan(num_pts, num_out, num_iter);
decoders = cell(num_iter,1);
figh     = nan(num_iter,num_out);

% bmi parameters:
E2F = E2F_deRugy_PD(15);
% params.emg_decoder = E2F;
% params.adapt_params.emg_patterns = get_optim_emg_patterns(E2F);

% adaptation parameters:
% aveFR = mean(mean(train_data.spikeratedata));
% ref_aveFR = 10.69; %from jango_20150107
% params.adapt_params.LR       = 5e-7*ref_aveFR/aveFR;
% if ~isfield(params,'emg_thresh') params.emg_thresh=0; end
% params.adapt_params.duration = inf;
% params.adapt_params.delay    = 0.65;
% params.adapt_params.lambda = 0.99;

for i = 1:num_iter
    
    [temp_train_data,~] = splitBinnedData(train_data,train_duration(i),train_data.timeframe(end));
    title_str = strrep(sprintf('%s - %s - %.1f min',train_data.meta.filename, type, train_duration(i)/60),'_','\_');
    
    switch type
        case 'normal'
            % use normal adaptive decoder training
            params.mode = 'emg_cascade';
            decoders{i} = adapt_offline(temp_train_data,params);
            [vaf(i,:),R2(i,:),preds(:,:,i),~,figh(i,:)] = plot_predsF(test_data,{decoders{i};E2F},params.mode,1,1,0,title_str);
        case 'supervised'
            % use adaptive decoder with actual force
            params.mode = 'direct';
            params.adapt_params.type = 'supervised';
            N2F = adapt_offline(temp_train_data,params);
            decoders{i} = N2F;
            [vaf(i,:),R2(i,:),preds(:,:,i),~,figh(i,:)] = plot_predsF(test_data,{N2F;[]},params.mode,1,1,0,title_str);
            
        case 'N2F_target'
            % use adaptive decoder with actual force
            params.mode = 'direct';
            params.adapt_params.type = 'N2F_target';
            N2F = adapt_offline(temp_train_data,params);
            decoders{i} = N2F;
            [vaf(i,:),R2(i,:),preds(:,:,i),~,figh(i,:)] = plot_predsF(test_data,{N2F;[]},params.mode,1,1,0,title_str);
            
        case 'optimal'
            % use optimal decoders
            params.mode = 'direct';
            params = bmi_params_defaults(params);
            N2F.H = filMIMO4(temp_train_data.spikeratedata,temp_train_data.cursorposbin,params.n_lag,1,1);
            N2F.neuronIDs = temp_train_data.neuronIDs;
            decoders{i} = N2F;
            [vaf(i,:),R2(i,:),preds(:,:,i),~,figh(i,:)] = plot_predsF(test_data,{N2F;[]},params.mode,1,1,0,title_str);
%             preds(:,:,i) = predMIMOCE3(test_data.spikeratedata,H);
%             R2(i,:)  = CalculateR2(preds(:,:,i),test_data.cursorposbin);
%             vaf(i,:) = calc_vaf(preds(:,:,i),test_data.cursorposbin);
        case 'supervised_full'
            %use gradient descent with actual force (all the data)
        case 'optimal_target'
            %use same data as adaptation wrt target onset, but train with
            %filMIMO4.
            params.mode = 'direct';
            params = bmi_params_defaults(params);
            numlags = params.n_lag;
            spikes = DuplicateAndShift(temp_train_data.spikeratedata,numlags);
            numlags = 1;
            [ct_i,ot_i] = get_epochs_data_idx(temp_train_data,params.adapt_params.delay);
            spikes = spikes(any([ct_i ot_i],2),:);
            force  = train_data.cursorposbin(any([ct_i ot_i],2),:);
            [n_bin,n_in]=size(spikes);
            if n_in>n_bin
                warning('not enough spike data: skipped opt_tgt for dur %.1f min data %s',...
                                train_duration(i)/60,temp_train_data.meta.filename);
                figh(i,:) = zeros(1,num_out);
                continue;
            end
            N2F.H = filMIMO4(spikes,force,numlags,1,1);
            N2F.neuronIDs = temp_train_data.neuronIDs;
            decoders{i} = N2F;
            [vaf(i,:),R2(i,:),preds(:,:,i),~,figh(i,:)] = plot_predsF(test_data,{N2F;[]},params.mode,1,1,0,title_str);            
        case 'emg'
            % use optimal decoders, predict EMGs
            H = filMIMO4(temp_train_data.spikeratedata,temp_train_data.emgdatabin,10,1,1);
            preds(:,:,i) = predMIMOCE3(test_data.spikeratedata,H);
            R2(i,:)  = CalculateR2(preds(:,:,i),test_data.emgdatabin);
            vaf(i,:) = calc_vaf(preds(:,:,i),test_data.emgdatabin);
    end
end
    

