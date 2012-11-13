
%makes a tdf from a bdf. tdf is the Tucker data format which extends
%the bdf by appending the trial table as a main element, and adding the
%firing rate to the unit sub elements


[bdf.tt,bdf.tt_hdr]=bc_trial_table4(bdf);
%[bdf.tt,bdf.tt_hdr]=rw_trial_table_hdr(bdf);

% ts = 50;
% offset=0;
% 
% if isfield(bdf,'units')
%     vt = bdf.vel(:,1);
%     t = vt(1):ts/1000:vt(end);
% 
%     for unit=1:length(bdf.units)
%         if isempty(bdf.units(unit).id)
%             bdf.units(unit).id=[];
%         else
%             spike_times = get_unit(bdf,bdf.units(unit).id(1),bdf.units(unit).id(2))-offset;
%             spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
%             bdf.units(unit).fr = [t;train2bins(spike_times, t)]';
%         end
%     end
% end

%tdf_bump=get_sub_trials(bdf, bdf)