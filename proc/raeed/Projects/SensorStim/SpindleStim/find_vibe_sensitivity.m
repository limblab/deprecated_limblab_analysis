function [figure_handles, output_data]=find_vibe_sensitivity(folder,options)
    try
        %%
        figure_handles=[];

    %     matfilelist=dir([folder filesep options.prefix '*.mat']);
    %     nevfilelist=dir([folder filesep options.prefix '*.nev']);
    %     if ~isempty(matfilelist)
    %         temp=load([folder filesep matfilelist(1).name]);
    %         y=fieldnames(temp);
    %         if length(y)==1
    %             NSx=temp.(y{1});
    %         else
    %             error('get_PDs: loaded multiple variables from .mat file')
    %         end
    %     elseif ~isempty(nevfilelist)
    %         NSx=cerebus2NEVNSx(folder,options.prefix);
    %     else
    %         error('get_PDs:found no matching files')
    %     end
        if(~isfield(options,'bdf') || ~isfield(options,'bdf'))
            if(folder(end)~=filesep)
                folder = [folder filesep];
            end
            bdf = get_nev_mat_data([folder options.prefix],options.labnum);
        else
            bdf = options.bdf;
        end
        %% prep bdf
        %add firing rate to the units fields of the bdf
        opts.binsize=0.05;
        opts.offset=-.015;
        opts.do_trial_table=0;
        opts.do_firing_rate=1;
        bdf=postprocess_bdf(bdf,opts);
        output_data.bdfpost_DL=bdf;

        %% figures
        figure_handles = [];
        
    catch MExc
        output_data.MExc = MExc;
        warning('Code did not fully execute. Check ''MExc'' in output data for more information.')
    end
end
