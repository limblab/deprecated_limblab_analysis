function [LEARBAR,REARBAR,LEYEBAR,REYEBAR,MIDLINE]=mrirotate(params,...
                          learbar,rearbar,leyebar,reyebar,midline);

a=params(1);
b=params(2);
c=params(3);

R=[cos(b)*cos(c),-cos(b)*sin(c),-sin(b);
   -sin(a)*sin(b)*cos(c)+cos(a)*sin(c),sin(a)*sin(b)*cos(c)+cos(a)*cos(c),-sin(a)*cos(b);
   cos(a)*sin(b)*cos(c)+sin(a)*sin(c),-cos(a)*sin(b)*sin(c)+sin(a)*cos(c),cos(a)*cos(b)];

% R=[cos(b)*cos(c),cos(b)*sin(c),sin(b);
%    -sin(a)*sin(b)*cos(c)+cos(a)*sin(c),sin(a)*sin(b)*cos(c)+cos(a)*cos(c),-sin(a)*cos(b);
%    cos(a)*sin(b)*cos(c)+sin(a)*sin(c),-cos(a)*sin(b)*sin(c)+sin(a)*cos(c),cos(a)*cos(b)];

k=[params(4);params(5);params(6)];

LEARBAR=R*(learbar+k);
REARBAR=R*(rearbar+k);
LEYEBAR=R*(leyebar+k);
REYEBAR=R*(reyebar+k);
MIDLINE=R*(midline+repmat(k,[1,size(midline,2)]));

