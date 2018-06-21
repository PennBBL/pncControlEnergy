function [avg_cont, mod_cont, bound_cont] = ControlCal_Function(ConnPath, ResultantFile)

%
% ConnPath:
%    The path of the .mat file which contains a matrix named 'connectivity'
%

tmp = load(ConnPath);
A = tmp.connectivity ./ (1 + svds(tmp.connectivity, 1));
avg_cont = ave_control(A);
mod_cont = modal_control(A);

save(ResultantFile, 'avg_cont', 'mod_cont');
