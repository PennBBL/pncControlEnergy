
function EnergyMerge_Function(EnergyFile_Cell, ResultantFile)

SubjectsQuantity = length(EnergyFile_Cell);
tmp = load(EnergyFile_Cell{1});
[TimepointsQuantity, TargetsQuantity] = size(tmp.X_Opt_Trajectory);
NodesQuantity = length(tmp.Energy);
% X_Opt_Trajectory = zeros(SubjectsQuantity, TimepointsQuantity, TargetsQuantity);
X_Opt_Final = zeros(SubjectsQuantity, TargetsQuantity);
% U_Opt_Trajectory = zeros(SubjectsQuantity, TimepointsQuantity, NodesQuantity);
Energy = zeros(SubjectsQuantity, NodesQuantity);
n_err = zeros(SubjectsQuantity, 1);
xc = zeros(SubjectsQuantity, NodesQuantity);
xf = zeros(SubjectsQuantity, NodesQuantity);

for i = 1:length(EnergyFile_Cell)
  tmp = load(EnergyFile_Cell{i});
%  X_Opt_Trajectory(i, :, :) = tmp.X_Opt_Trajectory;
  X_Opt_Final(i, :) = tmp.X_Opt_Final;
%  U_Opt_Trajectory(i, :, :) = tmp.U_Opt_Trajectory;
  Energy(i, :) = tmp.Energy;
  n_err(i) = tmp.n_err;
  xc(i, :) = tmp.xc;
  xf(i, :) = tmp.xf;
  [~, FileName, ~] = fileparts(EnergyFile_Cell{i});
  scan_ID(i) = str2num(FileName);
end
% save(ResultantFile, 'X_Opt_Trajectory', 'X_Opt_Final', 'U_Opt_Trajectory', 'Energy', 'n_err', 'xc', 'xf');
save(ResultantFile, 'X_Opt_Final', 'Energy', 'n_err', 'xc', 'xf', 'scan_ID');
