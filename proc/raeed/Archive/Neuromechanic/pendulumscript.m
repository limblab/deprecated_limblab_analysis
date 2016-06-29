nm = xml2matlab('threelink.nmco');                  % Convert xml to a matlab cell structure
bod = nm.NeuromechanicFile{1}.Bodies{1}.RigidBody;  % Get <RigidBody> elements
mass = 0;                                           % Initialize mass to zero
for ii = 1:length(bod)
    mass = mass+bod{ii}.Mass{1}.Value;              % Add total mass from each body
end;
dyn = nm.NeuromechanicFile{1}.Dynamics;             % Get <Dynamic> elements
g = nm.NeuromechanicFile{1}.Environment{1}.Gravity{1}.Value';   % Get gravity vector
n = length(dyn);                                    % Get the number of data points
t = zeros(n,1);                                     % Initialize time
KE = zeros(n,1);                                    % Initialize kinetic energy
COM = zeros(n,3);                                   % Initialize center of mass position
PE = zeros(n,1);                                    % Initialize potential energy
for ii = 1:n
    t(ii,1) = dyn{ii}.Time{1}.Value;                % Store time
    KE(ii,1) = dyn{ii}.ModelKineticEnergy{1}.Value; % Store kinetic energy
    COM(ii,:) = dyn{ii}.ModelCOM{1}.Value(1:3);     % Store center of mass position
    PE(ii,1) = -(COM(ii,:)-COM(1,:))*g*mass;        % Calculate potential energy w.r.t initial CoM Position
end;
plot(t,[KE PE KE+PE]);                              % Look at energy exchange
xlabel('Time (sec)')
ylabel('Energy (J)')
legend({'Kinetic Energy' 'Potential Energy' 'Total Energy'})