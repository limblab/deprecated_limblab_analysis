function present(th)
% PRESENT  Displays model properties with more information than
% DISPLAY.
%
% Model parameter uncertainties, if available, are displayed.


% old help 
%PRESENT  presents a parametric model on the screen.
%   PRESENT(TH)
%
%   This function displays the model TH together estimated standard
%   deviations, innovations variance, loss function and Akaike's Final
%   Prediction Error criterion (FPE).

%   L. Ljung 10-1-86
%   Copyright 1986-2014 The MathWorks, Inc.

if nargin < 1
   disp('Usage: PRESENT(TH)')
   return
end
th
 