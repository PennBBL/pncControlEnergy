
Predict_Folder = '/Users/zaixucui/Documents/Projects/pncControlEnergy/results/InitialDM1_TargetActivation/ExecFun_Prediction';
Ridge_Weight_Mat = [Predict_Folder '/Ridge_Sample1_Predict_Sample2_MeanEnergyAgeTBV/APredictB.mat'];
tmp = load(Ridge_Weight_Mat);
w_Brain_Actual = tmp.Weight;

Ridge_Weight_Random_Cell = g_ls([Predict_Folder '/Ridge_Sample1_Predict_Sample2_MeanEnergyAgeTBV_Permutation/Time_*/APredictB.mat']);
for i = 1:length(Ridge_Weight_Random_Cell)
  tmp = load(Ridge_Weight_Random_Cell{i});
  w_Brain_Random(i, :) = tmp.Weight;
end
figure
hist(w_Brain_Random(:, 1));
figure
hist(w_Brain_Random(:, 2));
figure
hist(w_Brain_Random(:, 3));

w_Brain_Actual = abs(w_Brain_Actual);
w_Brain_Random = abs(w_Brain_Random);
Substract = w_Brain_Random - repmat(w_Brain_Actual, 1000, 1);
Substract(find(Substract > 0)) = 1;
Substract(find(Substract < 0)) = 0;
w_Brain_P = sum(Substract) / 1000;

Sig_Index = find(w_Brain_P < 0.05);
w_Brain_Sig = zeros(size(w_Brain_Actual));
w_Brain_Sig(Sig_Index) = w_Brain_Actual(Sig_Index);
w_Brain_Sig_P = w_Brain_P(Sig_Index);
save([Predict_Folder '/Ridge_Sample1_Predict_Sample2_MeanEnergyAgeTBV/w_Brain_Sig.mat'], 'w_Brain_Sig', 'w_Brain_Sig_P');
