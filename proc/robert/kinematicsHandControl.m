function [PL,TTT]=kinematicsHandControl(out_struct)

% syntax PL=kinematicsHandControl(out_struct);
%
% calculates the path length & time-to-target for each 
% successful trial (RW) in a BDF-formatted out_struct
%
% out_struct.words should follow something like
%
%     1.7975   18
%     1.8654   49
%     2.7623   49
%     3.5522   49
%     4.2851   49
%     5.1169   49
%     5.8098   49
%     6.4248   32
%    ...
%    40.2363   18
%    40.3043   49
%    40.4573   33
%
% for a successful (6-target) trial (code 32), followed some time later
% by a new trial that ended with an abort (code 33) after the 
% presentation of the first target (code 49).  
% out_struct.words(...,2)=[18; 49; 18] would be a timeout.  
% Check Mini's files for fail codes.
   

start_reaches=out_struct.words(diff(out_struct.words(:,2))==0 | ...
	diff(out_struct.words(:,2))==-17,1);
end_reaches=out_struct.words(find(diff(out_struct.words(:,2))==0 | ...
	diff(out_struct.words(:,2))==-17)+1,1);

% the dumb way.
PL=zeros(size(start_reaches));
TTT=zeros(size(start_reaches));
for n=1:length(start_reaches)
	included_points=find(out_struct.pos(:,1)>=start_reaches(n) & ...
		out_struct.pos(:,1)<=end_reaches(n));
	if ~isempty(included_points)
		for k=2:length(included_points)
			PL(n)=PL(n)+ ...
				sqrt((out_struct.pos(included_points(k),2)-out_struct.pos(included_points(k-1),2))^2 + ...
				(out_struct.pos(included_points(k),3)-out_struct.pos(included_points(k-1),3))^2);
		end
		% normalize by the straight-line distance between the start and end
		% points
		interTargetDistance=sqrt(sum(diff(out_struct.pos(included_points([1 end]),2:3)).^2));
		PL(n)=PL(n)/interTargetDistance;
		TTT(n)=(end_reaches(n)-start_reaches(n))/interTargetDistance;
	end
end
PL(PL==0)=[];
TTT(TTT==0)=[];
