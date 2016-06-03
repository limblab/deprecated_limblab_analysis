function bd = split_data_wrt_targets(bd,numlags,delay)

bd.spikeratedata = DuplicateAndShift(bd.spikeratedata,numlags);
numlags = 1;

[ct_i, ot_i] = get_epochs_data_idx(bd,delay);

spikes = bd.spikeratedata( ct_i|ot_i,:);