function h=make_polar_plot_all_PDs(pds,varargin)
    %takes a vector of PDs and plots them as unit vectors in a polar circle

    if ~isempty(varargin)
        use_moddepth=1;
        moddepth=varargin{1};
    else
        use_moddepth=0;
    end
    h = figure;
    polar(0,1)
    hold on
    r=1;
    for i=1:length(pds)

        if use_moddepth
            polar([0 pds(i)],[0,moddepth(i)/max(moddepth)],'b');
        else
            polar([0 pds(i)],[0,r],'b');
        end
    end
end