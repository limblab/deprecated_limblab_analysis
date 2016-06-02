function cost = elastic_joint_cost(angles,eq_angles)
%Cost to find limb configuration in elastic joint condition

cost = sum((angles(:)-eq_angles(:)).^2);