function eye_plus_cursor = get_positions(bdf)
%Input is a bdf with eye tracking data, output is an N x 5 matrix of the
%form:  [  t   eye_x   eye_y   cursor_x   cursor_y  ] (this function
%simply combines eye and cursor position data into one matrix with
%corresponding timestamps)

if ~isempty(bdf.eye)
    
    eyes = bdf.eye;
    curs = bdf.pos;

    t = 1;
    x = 2;      %coordinate indices within bdf struct
    y = 3;

    %Get column vectors giving 'ts': time stamp at which each position is
    %recorded (only for timestamps existing in *both* 'eye' and 'pos' structs);
    %'i_eye': indices of the values of the intersecting time stamps (should be
    %all of them for the 'eye' struct); and 'i_cur': indices of the values of
    %the intersecting time stamps in the 'pos' struct (should be same number of
    %them as length of 'bdf.eye')
    [ts, i_eye, i_cur] = intersect( eyes(:,t), curs(:,t) );

    %Create output matrix that contains position of both eye and of cursor with
    %corresponding time stamp
    eye_plus_cursor = [ ts eyes(i_eye, x) eyes(i_eye, y) curs(i_cur, x) curs(i_cur, y) ];
    
else
    
    eye_plus_cursor = 0;
    
end
