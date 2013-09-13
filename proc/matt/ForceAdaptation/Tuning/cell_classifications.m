% This stores the info to classify cells based on the "difference matrix"
% that I calculate in classifyCells
%
% The matrix is filled in as shown below comparing the tuning of each epoch
% to the others. It ends up being an upper triangular matrix with a 1 if
% the difference between the epoch in the row and the epoch in the column
% is significant. Thus, the diagonal is always zero and the lower portion
% would be a mirror image of the upper portion so I just don't fill it in.
%
%       BL  AD  WO
%    BL 0   _   _
%    AD 0   0   _
%    WO 0   0   0
%
% Based on the pattern, I can convert the difference matrix into a unique
% number by multiplying elementwise with the converter matrix and summing
% along both directions to get a single value that can be used to classify
% the cell. The patterns are shown below. The number above each category is
% how I identify them in the code. The number to the right of each pattern
% is what they sum to when multiplied by the converter matrix.
%
% Note that I care mostly about how the epoch compare to baseline (the top
% row). Sometimes there are some weird things... for instance, a cell that
% has no change from BL->AD and BL->WO, but does change from AD->WO. These
% situations are shown in the second row below.
%
%       1                   2                 3                  4                  5
% Kinematic (AAA)  |  Dynamic (ABA)  |  Memory I (ABB)  |  Memory II (AAB)  |  Other (ABC)
%     0 0 0        |      0 1 0      |      0 1 1       |      0 0 1        |     0 1 1
%     0 0 0   0    |      0 0 1   8  |      0 0 0   5   |      0 0 1   9    |     0 0 1   11
%     0 0 0        |      0 0 0      |      0 0 0       |      0 0 0        |     0 0 0
%      OR                  OR                                   OR
%     0 0 0        |      0 1 0      |                  |      0 0 1        |
%     0 0 1   6    |      0 0 0   2  |                  |      0 0 0   3    |
%     0 0 0        |      0 0 0      |                  |      0 0 0        |

%%%%%%%%%%%%%%%%%%%
converterMatrix = [1 2 3; ...
                   4 5 6; ...
                   7 8 9];
               
%%%%%%%%%%%%%%%%%%%
% first column is converted value, second is classification number
classMapping = [ 0, 1; ... %kinematic
                 6, 1; ... %kinematic
                 8, 2; ... %dynamic
                 2, 2; ... %dynamic
                 5, 3; ... %memory i
                 9, 4; ... %memory ii
                 3, 4; ... %memory ii
                11, 5]; %other
            
            