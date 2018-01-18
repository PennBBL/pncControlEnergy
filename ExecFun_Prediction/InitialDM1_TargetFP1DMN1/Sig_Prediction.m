
Prediction_ResultantFolder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction';
Prediction = load([Prediction_ResultantFolder '/Ridge_3FCV/Res_NFold.mat']);
Actual_Corr = Prediction.Mean_Corr;
Actual_MAE = Prediction.Mean_MAE;

Permutation_Folder = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_3FCV_Permutation';
PermuRes_Cell = g_ls([Permutation_Folder '/*/Res_NFold.mat']);
for i = 1:length(PermuRes_Cell)
  tmp = load(PermuRes_Cell{i});
  Rand_Corr(i) = tmp.Mean_Corr;
  Rand_MAE(i) = tmp.Mean_MAE;
end
P_Corr = length(find(Rand_Corr >= Actual_Corr)) / length(Rand_Corr);
P_MAE = length(find(Rand_MAE <= Actual_MAE)) / length(Rand_MAE);

save /data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Sig_Prediction.mat P_Corr P_MAE;
