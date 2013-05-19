% Use this when adjusting the encoders for a robot.
% 1. Fix the arm the default position 
%   (upper arm pointing out of robot towards subject, 
%   lower arm pointing to the right)
% 2. Loosen motor shaft from flex couplers
% 3. Run this script
% 4. Turn encoder shafts until both Encoder 1 and Encoder 2
%   read a value of zero
% 5. Tighten motor shaft to flex couplers again
% 6. Stop this scipt by typing "Ctrl + c"

tg = xpc;

enc1_id  = tg.getsignalid('XY Position Subsystem/PCI-QUAD04 ');
enc2_id  = tg.getsignalid('XY Position Subsystem/PCI-QUAD04 1');

while 1
    disp(['Encoder 1: ' num2str(getsignal(tg,enc1_id))]) 
    disp(['Encoder 2: ' num2str(getsignal(tg,enc2_id))])
    pause(.1)
    clc
end