
function [X_Opt_Trajectory, X_Opt_Final, U_Opt_Trajectory, Energy, n_err] = EnergyCal_Function(ConnPath, scale_factor, T, xc, x0, xf, rho, ResultantFile)

load(ConnPath);
A = connectivity ./ scale_factor;
A = A - 2*max(real(eig(A)))*eye(size(A)); % scale to be stable, makes calculation more tractable

[X_Opt_Trajectory, X_Opt_Final, U_Opt_Trajectory, Energy, n_err] = optim_fun(A, T, diag(xc), x0, xf, rho);
save(ResultantFile, 'X_Opt_Trajectory', 'X_Opt_Final', 'U_Opt_Trajectory', 'Energy', 'n_err', 'xc', 'xf');
