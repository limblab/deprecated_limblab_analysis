function eyeplus_data = sort_eye_data(eye_data)

%The input 'eye_data' is of the form [ ts eye_x eye_y cursor_x cursor_y ], which
%already has been through the blink filter (as a part of the
%'calc_from_raw' function). This function cuts out values not closely
%associated with target locations. First we will start with simply
%narrowing the viewing field (cut out extreme x- and y-values,
%"extreme" defined by looking at a plot of eye_x vs eye_y and finding a
%suitable range)

t = 1;
x = 2;
y = 3;      %position indices in 'eye_data' matrix
px = 4;
py = 5;
y_min = -12;
y_max = 10;     %These values gotten by looking at a plot of POG and seeing range of values that were of interest
x_min = -10;
x_max = 10;


%--------------Removes values outside the behavior workspace---------------
%First, narrow down based on constraints on x-axis
t_valid  = eye_data( find( eye_data(:,x) > x_min ), t );
ix_valid = eye_data( find( eye_data(:,x) > x_min ), x );
iy_valid = eye_data( find( eye_data(:,x) > x_min ), y );
px_valid = eye_data( find( eye_data(:,x) > x_min ), px );
py_valid = eye_data( find( eye_data(:,x) > x_min ), py );

t_valid  =  t_valid( find( ix_valid <  x_max ) );
ix_valid = ix_valid( find( ix_valid <  x_max ) );
iy_valid = iy_valid( find( ix_valid <  x_max ) );
px_valid = px_valid( find( ix_valid <  x_max ) );
py_valid = py_valid( find( ix_valid <  x_max ) );

%Second, narrow further based on constraints on y-axis
t_valid  =  t_valid( find( iy_valid > y_min ) );
ix_valid = ix_valid( find( iy_valid > y_min ) );
iy_valid = iy_valid( find( iy_valid > y_min ) );
px_valid = px_valid( find( iy_valid > y_min ) );
py_valid = py_valid( find( iy_valid > y_min ) );

t_valid  =  t_valid( find( iy_valid < y_max ) );
ix_valid = ix_valid( find( iy_valid < y_max ) );
iy_valid = iy_valid( find( iy_valid < y_max ) );
px_valid = px_valid( find( iy_valid < y_max ) );
py_valid = py_valid( find( iy_valid < y_max ) );


%---Finding offset (defined in behavior program, not currently avail. in bdf)-----
aveix = mean(ix_valid);
aveiy = mean(iy_valid);
avepx = mean(px_valid);
avepy = mean(py_valid);

offset_x = avepx - aveix;
offset_y = avepy - aveiy;

px_valid = px_valid - offset_x; %center the cursor coordinates onto the eye coordinates
py_valid = py_valid - offset_y;


% At this point, about 5% of the data has been removed for being "out of
% bounds"
eyeplus_data = [ t_valid ix_valid iy_valid px_valid py_valid ];

%Difference between individual coordinates of the eye and the cursor
%xdiff  =  [ eye_targets(:,1) (eye_targets(:,4) - eye_targets(:,2)) ];
%ydiff  =  [ eye_targets(:,1) (eye_targets(:,5) - eye_targets(:,3)) ];

%The magnitude of the 2-D vector going from the eye towards the cursor
%sqdiff =  [ xdiff(:,1) sqrt(abs( xdiff(:,2).^2 + ydiff(:,2).^2 )) ];
%The vector going from the eye towards the cursor (time is the 3rd dim.)
%vecdiff = [ xdiff(:,1) xdiff(:,2) ydiff(:,2) ];




