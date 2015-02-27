function bdf=postprocess_bdf(bdf,varargin)
    %makes a tdf from a bdf. tdf is the Tucker data format which extends
    %the bdf by appending the trial table as a main element, and adding the
    %firing rate to the unit sub elements
    if length(varargin>0)
        opts=varargin{1};
    else
        opts.do_firing_rate=1;
        opts.do_trial_table=1;
    end
    if opts.do_trial_table
        switch bdf.meta.task
            case 'RW'
                [bdf.TT,bdf.TT_hdr]=rw_trial_table_hdr(bdf);
            case 'BC'
                [bdf.TT,bdf.TT_hdr]=bc_trial_table4(bdf);
            otherwise
                error('make_tdf_function:UnidentifiedTask','The bdf.meta.task field is empty or contains an unrecognized task code')
        end
    end
    %
    %
    if opts.do_firing_rate & isfield(bdf,'units')
        if isfield(opts,'binzise')
            ts=opts.binzise;
        else
            ts=.050;
        end
        %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead
        if isfield(opts,'offset')
            offset=opts.offset;
        else
            offset=0;
        end
        vt = bdf.vel(:,1);
        t = vt(1):ts:vt(end);

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

end

