
WorkFolder = '/data/jux/BBL/projects/pncControlEnergy/results/InitialDM1_TargetActivation/Energy_Activation_Relationship';
TrueACC = load([WorkFolder '/CCA_Energy_Activation.mat']);
x = g_ls([WorkFolder '/CCA_Energy_Activation_Permutation/Time_*/Res.mat']);
for i = 1:length(x)
    tmp = load(x{i});
    CCA_Corr_Random(i, :) = tmp.CCACorr;
end
for i = 1:233
    P_Energy_Activation(i) = length(find(CCA_Corr_Random(:, i) > TrueACC.CCACorr(i))) / 1000;
end

TrueACC = load([WorkFolder '/CCA_Energy_ActivationAbs.mat']);
load([WorkFolder '/CCA_Energy_ActivationAbs_Permutation.mat']);
for i = 1:233
    P_Energy_ActivationAbs(i) = length(find(CCA_Corr_Random(:, i) > TrueACC.CCACorr(i))) / 1000;
end

TrueACC = load([WorkFolder '/CCA_EnergyLog2_Activation.mat']);
load([WorkFolder '/CCA_EnergyLog2_Activation_Permutation.mat']);
for i = 1:233
    P_EnergyLog2_Activation(i) = length(find(CCA_Corr_Random(:, i) > TrueACC.CCACorr(i))) / 1000;
end

TrueACC = load([WorkFolder '/CCA_EnergyLog2_ActivationAbs.mat']);
x = g_ls([WorkFolder '/CCA_EnergyLog2_ActivationAbs_Permutation/Time_*/Res.mat']);
for i = 1:length(x)
    tmp = load(x{i});
    CCA_Corr_Random(i, :) = tmp.CCACorr;
end
for i = 1:233
    P_EnergyLog2_ActivationAbs(i) = length(find(CCA_Corr_Random(:, i) > TrueACC.CCACorr(i))) / 1000;
end

save([WorkFolder '/CCA_P.mat'], 'P_Energy_Activation', 'P_Energy_ActivationAbs', 'P_EnergyLog2_Activation', 'P_EnergyLog2_ActivationAbs');
