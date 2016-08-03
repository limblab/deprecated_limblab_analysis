%% NORM_CW computes the Euclidean norms of each row-vector of a matrix 
%
%Mn = norm_cw(M) computes the euclidean norm of the row-vectors in the
%N-by-N matrix M. Its output is a N-by-1 vector.
%
%INPUTS:
%
%M: N-by-M matrix.
%
%OUTPUTS:
%
%vn: N-by-1 vector containing the Euclidean normd of the row of M.
%    
%Author: Cristiano Alessandro (cristiano.alessandro@northwestern.edu)
%Date: April 04 2016
%Licence: GNU GPL

%% Copyright (c) 2016 Cristiano Alessandro <cristiano.alessandro@northwestern.edu>
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program. If not, see <http://www.gnu.org/licenses/>.
%

function vn = norm_cw(M)

    vn = sqrt(sum(M.^2,2));
    %Mn = repmat(vn,1,size(M,2)); % In case I want to repeat the vector
                                 %into a matrix
    
end