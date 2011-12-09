function [PL,TT]=kinematicsBrainControl(out_struct,BRarray,startTime)

% syntax [PL,TT]=kinematicsBrainControl(out_struct,BRarray,startTime);
%
% calculates the path length traveled by the cursor for each 
% successful trial (RW). Cursor position data in BRarray.  
% x-pos=BRarray(:,3), y-pos=BRarray(:,4).  Checks for zero-valued times in
% the time column BRarray(:,7).  Scales times to seconds; sets 1st row
% initially to t=0, then cuts off startTime seconds as occurring before the
% beginning of out_struct.  Then, re-initialize time vector before
% comparing to trials determined by out_struct words.
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
   
% get rid of any lead-in data
tmp=size(BRarray,1);
BRarray(BRarray(:,7)==0,:)=[];
fprintf(1,'deleted %d lines with time stamp=0\n',tmp-size(BRarray,1))

% scale time vector
BRarray(:,7)=BRarray(:,7)/1e9;
BRarray(:,7)=BRarray(:,7)-BRarray(1,7);

% remove anything < startTime
tmp=size(BRarray,1);
BRarray(BRarray(:,7)<startTime,:)=[];
fprintf(1,'deleted %d lines that occurred before %.2f\n',tmp-size(BRarray,1),startTime)
disp('resetting BRarray(1,7)=0')
BRarray(:,7)=BRarray(:,7)-BRarray(1,7);

% put it into the expected format
out_struct.pos=BRarray(:,[7 3 4]);
% now the hand control function will work.
[PL,TT]=kinematicsHandControl(out_struct);
