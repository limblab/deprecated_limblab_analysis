%% PROJECT_V2P projects a set of vectors onto a plane
%
%[v_prj, v_prj_p] = project_v2p(v,n,p)
%
%INPUTS:
%
%v: N-by-3 matrix where each row is a vector (to be projected)
%n: normal vector to the plane
%p: a point on the plane
%
%OUTPUTS:
%
%v_prj: N-by-3 matrix where each row is the projection of the
%corresponding row of v onto the plane (wrt the original FoR)
%
%v_prj_p: N-by-3 matrix where each row is the projection of the
%corresponding row of v onto the plane (wrt the point p on the plane)
%
%The vectors v may or may not be expressed in a coordinate system that
%lays on the plane. The output v_prj are expressed in the same 
%coordinate system as the original vectors v.
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

function [v_prj, v_prj_p] = project_v2p(v,n,p)    

    M       = bsxfun(@minus,v,p);      % Vectors from p to v
    prj     = M*n';  % Projections of the points onto the normal vector
    prj_n   = prj*n; % Translate projections into vectors on the normal
    v_prj_p = M - prj_n;               % Vectors on the plane (wrt p)
    v_prj   = bsxfun(@plus,v_prj_p,p); % (wrt original FoR)

end