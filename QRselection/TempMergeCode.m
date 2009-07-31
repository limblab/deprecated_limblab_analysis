
load InputSelectThorFES03550msecbinA.mat

AICa=AICneuronsall;
IDXa=IDXall;
MDLa=MDLneuronsall;
R2fita=R2fit;
R2xvala=R2xval;
neurons95a=neurons95all;

clear AICneuronsall IDXall MDLneuronsall R2fit R2xval R2xvall neruons95all

load InputSelectThorFES03550msecbinB.mat


AICneuronsall=[AICa; AICneuronsall];
IDXall=[IDXa; IDXall];
MDLneuronsall=[MDLa; MDLneuronsall];
R2fit=[R2fita; R2fit];
R2xval=[R2xvala; R2xval];
neurons95all=[neurons95a; neurons95all];