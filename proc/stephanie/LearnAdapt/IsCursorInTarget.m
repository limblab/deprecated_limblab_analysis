% IsCursorInTarget 
function cursorintargetstatus = IsCursorInTarget(xPosition, yPosition, trialtable)

for i = 1:length(trialtable(:,1))
radiusX = trialtable(i,4)-trialtable(i,2);
radiusY = trialtable(i,3)-trialtable(i,5);

find(Xposition(A) >= (xCenter(N)-radiusX) & SingleTrialPositionsX(A) <= (xCenter(N)+radiusX) & SingleTrialPositionsY(A) <= (yCenter(N)+radiusY) & SingleTrialPositionsY(A) >= (yCenter(N)-radiusY),1);
           
find(Xposition(i) >= (LLx+radiusX) & Xposition(i) >= LLx & Yposition(i) >= (LLy+radiusY) & Xposition(i) >= LLy)