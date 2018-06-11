% compute optimal inputs/trajectories
% Fabio, Tommy September 2017
%
% -------------- Change Log -------------
% JStiso April 2018
%   Changed S to be an input, rather than something defined internally

% Inputs:
% A     (NxN) Structural connectivity matrix
% B     (NxN) Input matrix: selects which nodes to put input into. Define
%       so there is a 1 on the diagonal of elements you want to add input to, 
%       and 0 otherwise 
% S     (NxN) Selects nodes whose distance you want to constrain, Define so
%       that there is a 1 on the diagonal of elements you want to
%       constrain, and a zero otherwise
% T     Time horizon: how long you want to control for. Too large will give
%       large error, too short will not give enough time for control
% rho   weights energy and distance constraints. Small rho leads to larger
%       energy

function [X_Opt_Trajectory, X_Opt_Final, U_Opt_Trajectory, Energy, n_err] = optim_fun(A, T, B, x0, xf, S, rho)

n = size(A,2);

Sbar = eye(n) - S;

Atilde = [A -B*B'/(2*rho) ; -2*S -A'];

M = expm(Atilde*T);
M11 = M(1:n,1:n);
M12 = M(1:n,n+1:end);
M21 = M(n+1:end,1:n);
M22 = M(n+1:end,n+1:end);

N = Atilde\(M-eye(size(Atilde)));
c = N*[zeros(n);S]*2*xf;
c1 = c(1:n);
c2 = c(n+1:end);

p0 = pinv([S*M12;Sbar*M22]) * (-[S*M11;Sbar*M21]*x0 - [S*c1;Sbar*c2] + [S*xf;zeros(n,1)]);

n_err = norm([S*M12;Sbar*M22]*p0 - (-[S*M11;Sbar*M21]*x0 - [S*c1;Sbar*c2] + [S*xf;zeros(n,1)])); % norm(error)

sys_xp = ss(Atilde,[zeros(n);S],eye(2*n),0);

STEP = 0.001;
t = 0:STEP:T;

U = [];
while size(U,1) < length(t)
    U = [U;2*xf'];
end

[Y,tt,xp] = lsim(sys_xp,U,t,[x0;p0]);

for i = 1:length(t)
    U_Opt_Trajectory(i,:) = -(1/(2*rho))*B'*xp(i,n+1:end)';
end

X_Opt_Trajectory = xp(:, find(xf));
X_Opt_Final = xp(end, find(xf));
Energy = sum(U_Opt_Trajectory.^2 * STEP);

end
