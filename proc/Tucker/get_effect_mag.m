function effect_mag=get_effect_mag(params_no_stim, params_stim,bump_mag)
    %estimates the magnitude of the effect of stimulus on the
    %percept. Assumes that at a bump angle of 90deg, the percept from
    %stimulus is orthogonal to the mechanically driven percept
    
    %get the observed rate at 90degrees
    R_90_stim=sigmoid_stim(params_stim,90);
    
    %get the angle under no stim conditions which produces the same
    %reaching rate
    optifun=@(x) tempfun(R_90_stim,params_no_stim,x);
    percept_angle=fminsearch(optifun, 80);
    function err=tempfun(R,params,x)
        err=abs(sigmoid_stim(params,x)-R);
    end
    effect_mag=bump_mag*tan(90-percept_angle)-90;
end