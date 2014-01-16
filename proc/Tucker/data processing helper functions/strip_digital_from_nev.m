function strip_digital_from_nev( fname )
%strip_digital_from_nev(fname) saves a new copy of an .nev file without
%digital information
    disp(strcat('Opening file: ',fname))
    NEV=openNEV(fname,'report','nomat','nosave');
    savename=strcat(fname(1:end-4),'_nodigital.nev');
    disp(strcat('Stripping digital data and re-saving as: ',savename))
    saveNEVOnlySpikes2(NEV,savename)
end

