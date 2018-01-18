
Ridge_Weight_Mat = '/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_Weight/w_Brain.mat';
tmp = load(Ridge_Weight_Mat);
w_Brain_Actual = tmp.w_Brain;
Ridge_Weight_Random_Cell = g_ls('/data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Ridge_Weight_Permutation/*/w_Brain.mat');
for i = 1:length(Ridge_Weight_Random_Cell)
  tmp = load(Ridge_Weight_Random_Cell{i});
  w_Brain_Random(i, :) = tmp.w_Brain;
end
w_Brain_Actual = abs(w_Brain_Actual);
w_Brain_Random = abs(w_Brain_Random);
Substract = w_Brain_Random - repmat(w_Brain_Actual, 1000, 1);
Substract(find(Substract > 0)) = 1;
Substract(find(Substract < 0)) = 0;
w_Brain_P = sum(Substract) / 1000;

Sig_Index = find(w_Brain_P < 0.05);
w_Brain_Sig = zeros(size(w_Brain_Actual));
w_Brain_Sig(Sig_Index) = w_Brain_Actual(Sig_Index);
save /data/joy/BBL/projects/pncControlEnergy/results/ExecFun_Prediction/Sig_w_Brain.mat w_Brain_Sig;
