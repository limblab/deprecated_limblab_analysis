function [T] = translate(x, y, z)
% translate
% =========
% Generates a 4x4 translation matrix for Post-Multiplication 
% of a transformation matrix (OpenGL and AUTOLEV form)
% 
% Dan Moran
% The Neurosciences Institute
% 7-13-1999
% *********************************************************  
  
  T = [1 0 0 x;
       0 1 0 y;
       0 0 1 z;
       0 0 0 1];

