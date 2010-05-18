function score = eye_calib(paras,data)
%Only good for retroactive processing (will not work for closed-loop
%control)

%Auto-calibration routine written by Konrad Kording (April 1, 2010) for use
%with ASL eye-tracking camera; input is "bdf.eye" struct with position coords 
%added in, of form [ t  eye_x  eye_y  pos_x  pos_y ] (use intersect fn to
%pull pos_x and pos_y for times that match filtered eye data)

%this is just here temporarily to allow only input to be the bdf
%paras = [.65 .0 .02 .25 10 -27];

%small function that pulls position data from the bdf.eye and bdf.pos
%structs and outputs an N x 5 matrix
%data = get_positions(bdf);

W = reshape(paras(1:4),2,2);
V = paras(5:6);
%indices of "data" columns
x = 2;      % x-coord of the eye
y = 3;      % y-coord of the eye
px = 4;     % x-coord of the cursor
py = 5;     % y-coord of the cursor

nGood = find( (data(:,y) < 20) .* (data(:,x) > -10) ); %excluding artifacts
pred  = data(:,x:y)*W + ( V'*ones(1, size(data,1)) )';
distVect = sum( (( data(:,px:py) - pred ).^2)' ); %#ok<UDIM>
%score=sum(distVect(nGood))
score = -sum( distVect(nGood) < 5 ); %#ok<FNDSB>
%keyboard


%I called it by typing:
% " [paras,score] = fminsearch(@eye_calib,[.65 .0 .02 .25 10 -27],[], 
% eye_pos2) "    **'eye_pos2' is a .mat file (a matrix of the form
% [ t  x  y  px  py ] )**
%These initial values (.65 .0 ... ) I [Konrad] got by first running the routine with the square cost function (commented).
%The solution it gets me has 54398 samples out of 139644 non artifact samples with a precision of less than sqrt(5).
%In other words, in about a third of the time the calibration is really really precise.
%Which is approximately what we should expect.

%Final calibration values are
%W = [0.5841    0.0004    
%     0.0215    0.2114]
%V=  [9.7788  -27.3945]

%This is assuming as in the code above that
%cursor_position = W*eye_position + V;