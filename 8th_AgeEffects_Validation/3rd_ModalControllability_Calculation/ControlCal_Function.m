function [avg_cont, mod_cont, bound_cont] = ControlCal_Function(ConnPath, ResultantFile)

%
% ConnPath:
%    The path of the .mat file which contains a matrix named 'connectivity'
%

tmp = load(ConnPath);
A = tmp.connectivity;
mod_cont = modal_control(A);

save(ResultantFile, 'mod_cont');
