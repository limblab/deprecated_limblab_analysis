function [err]=mrierr(params,learbar,rearbar,leyebar,reyebar,midline)

[LEARBAR,REARBAR,LEYEBAR,REYEBAR,MIDLINE]=mrirotate(params,...
    learbar,rearbar,leyebar,reyebar,midline);

err=LEARBAR(1)^2+LEARBAR(3)^2+REARBAR(1)^2+REARBAR(3)^2+LEYEBAR(3)^2+...
    REYEBAR(3)^2+sum(MIDLINE(2).^2);

