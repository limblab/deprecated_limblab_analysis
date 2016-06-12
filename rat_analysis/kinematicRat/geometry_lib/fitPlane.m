%% FITPLANE fits a plane to a set of points (least square)
%
%[n,d,p] = fitPlane (data)
%
%INPUTS:
%
%data: N-by-3 matrix where each row is a point used for the fit
%
%OUTPUTS:
%
%n: 1-by-3 vector normal to the plane
%d: distance of the plane from the origin
%p: a point on the plane (centroid of the points on data)
%
%The element of n are the (a,b,c) coefficients of the equation ax+by+cz=d.
%The plane is therefore n(1)*x+n(2)*y+n(3)*z=d.
%
%This function is ispired by Adrien Leygue's affine_fit 
%(http://www.mathworks.com/matlabcentral/fileexchange/43305-plane-fit/content/affine_fit.m)
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

function [n,d,p] = fitPlane (data)

    p = mean(data,1);            % Centroid (point on the plane)
    M = bsxfun(@minus,data,p);   % Points centered around centroid

    [U,S,V] = svd(M);

    % The eigenvector associated to the smallest eigenvalue of the matrix
    % M'M (which correspond to the singlevector associated to the smallest
    % signularvalue of the matrix M) represents the direction of the
    % smallest variance of the data in M. Hence, the third singular vector
    % represents the normal vector to the plane that best fit the data (in
    % the least square sense).
    
    % The components of n represent also the (a,b,c) coefficients of the
    % plane ax+by+cz=d
    n = V(:,3)'; % NORMAL 
    
    % Distace of the plane from the origin
    d = dot(n,p);

end
