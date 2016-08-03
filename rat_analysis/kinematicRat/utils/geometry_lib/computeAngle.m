% alfa = COMPUTEANGLE ( p1, p2, p3 ) computes the angle between two vectors (in 
% degrees). The vectors originate from the point p2 and point to p1 and p3. 
% The points p1, p2 and p3 are expressed in a global frame of reference.
%
%INPUTS:
%
%p1, p2, p3: These variables can be bi-dimensional vectors,
%three-dimensional vectors, N-by-2 matrices or N-by-3 matrices. 
%In the first two cases, the function computes the angle (in radians) 
%between the vectors (2D or 3D). If p1, p2 and p3 are N-by-2 (or N-by-3) 
%matrices, the function computes the angles between each row of p1-p2 and 
%the corresponding one of p3-p2. These three variables must have the same
%size, ie. size(p1)==size(p2)==size(p3).
%
%OUTPUTS:
%
%alfa: angle between the vectors p1-p2 and p3-p2 (degrees)
%
%Author: Cristiano Alessandro (cristiano.alessandro@northwestern.edu)
%Date: April 07 2016
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

function alfa = computeAngle( p1, p2, p3 )

    if min(size(p1))==1
        
        p1_sM = max(size(p1));
        p2_sM = max(size(p2));
        p3_sM = max(size(p3));
        
        if ~(p1_sM==2 && p2_sM==2 && p3_sM==2) && ...
           ~(p1_sM==3 && p2_sM==3 && p3_sM==3)
       
            error('Points must have the same dimensions (2 or 3)!');
        end
        
        p1 = p1(:); % point 1
        p2 = p2(:); % point 2
        p3 = p3(:); % point 3
        
        v1 = p1-p2; % vector 1
        v2 = p3-p2; % vector 2

        cos12 = (v1'*v2)/(norm(v1)*norm(v2)); % cosine between v1 nad v2
        alfa  = acos(cos12);                  % angle btw v1 and v2 [rad]
        
    else
        
        if ~(size(p1,2)==2 && size(p2,2)==2 && size(p3,2)==2) && ...
           ~(size(p1,2)==3 && size(p2,2)==3 && size(p3,2)==3)
       
            error(['All input variables must have the same dimension. ' ...
                   'They can be either N-by-3 or N-by-2 matrices']);
        end
        
        v1 = p1-p2; % vectors 1
        v2 = p3-p2; % vectors 2
        
        v1_n = norm_cw(v1);
        v2_n = norm_cw(v2);

        v1_n1 = v1./repmat(v1_n,1,size(v1,2)); % normalize
        v2_n1 = v2./repmat(v2_n,1,size(v2,2)); % normalize

        cos12 = diag(v1_n1*v2_n1'); % cosines between corresponding vectros
        alfa  = acos(cos12);	    % angles between v1 and v2 [rad]
        alfa  = alfa .* 180/pi;     % angles between v1 and v2 [degree]
        
    end
        
end

