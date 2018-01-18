% main script
% Tommy october 2017

clc
clear all

scale_factor = 1200;

% adjacency matrix
load /data/joy/BBL/projects/pncClinDtiControl/data/matrices_withoutBrainStem/Lausanne125/SC/2796_streamlineCount_LausanneScale125.mat;
A =  connectivity / scale_factor;
A = A - 2*max(real(eig(A)))*eye(size(A)); % scale to be stable, makes calculation more tractable
n = size(A,1);

T = 1; % final time

rho = 1; % weight for control action in cost functional

%% control nodes selection
xc = ones(n,1); % Use the whole-brain as the control set

Yeo_partition = load('/data/joy/BBL/projects/pncClinDtiControl/data/atlas/Yeo_7system_in_Lausanne234.txt');
Yeo_partition = Yeo_partition(1:233);
Yeo_partition(find(Yeo_partition ~= 6 & Yeo_partition ~= 7)) = 0;
% initial state
% x0 = zeros(n,1); % the 1st condition
% x0 = Yeo_partition; x0(find(x0 == 7)) = 1; x0(find(x0 == 6)) = 0; % the 2nd condition
x0 = Yeo_partition; x0(find(x0 == 7)) = 1; x0(find(x0 == 6)) = -1; % the 3rd condition


%% target state setting
% r = 20; % number of target states
% xf = zeros(n,1); % target state
xf = Yeo_partition;
xf(find(xf == 6)) = 1;
xf(find(xf == 7)) = -1;

%%
[X_Opt_Path, X_Opt_Final, U_Opt_Path, Energy, n_err] = optim_fun(A, T, diag(xc), x0, xf, rho);

disp('Final state of the target nodes')
%X_opt(end, find(xf))
disp(' ')
disp('Norm of error (precision of the control!)')
n_err
