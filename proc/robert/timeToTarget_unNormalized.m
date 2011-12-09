function TTT=timeToTarget_unNormalized(out_struct)

% syntax TTT=timeToTarget_unNormalized(out_struct);
%
% originally meant for use with brain control files that lack accompanying
% BR *.txt files.

% need to figure out what code 160 means!

start_reaches=out_struct.words(diff(out_struct.words(:,2))==0 | ...
	diff(out_struct.words(:,2))==-17,1);
end_reaches=out_struct.words(find(diff(out_struct.words(:,2))==0 | ...
	diff(out_struct.words(:,2))==-17)+1,1);
TTT=end_reaches-start_reaches;
