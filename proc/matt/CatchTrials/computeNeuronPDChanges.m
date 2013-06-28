function changes = computeNeuronPDChanges(varargin)
% Computes changes in PD
% takes as an input any number of equally-sized vectors and outputs an
% array where each column represents the difference of the first input and
% subsequent inputs. For example, if there are three inputs A,B,C, the output
% will have 3 columns with the first being unitIDs, the second being B-A and
% the third being C-A. This assumes that every input has the same number of
% units. Also, the PDs should be angles

firstPD = varargin{1};
nUnits = size(firstPD,1);

changes = zeros(nUnits,length(varargin));
changes(:,1) = firstPD(:,1);

for i = 2:length(varargin)
    tempPD = varargin{i};
    changes(:,i) = firstPD(:,2)-tempPD(:,2);
end