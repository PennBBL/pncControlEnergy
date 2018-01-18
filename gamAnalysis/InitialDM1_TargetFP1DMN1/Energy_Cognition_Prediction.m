
Energy_Mat = load('/data/joy/BBL/projects/pncClinDtiControl/data/energyData/SC_Energy/SC_Initial_DM.mat');
Cognition_Mat = load('/data/joy/BBL/projects/pncClinDtiControl/data/subjectData/n1089_cnb_factor_scores_tymoore_20151006.mat');

OverallAccuracy = Cognition_Mat.OverallAccuracy;
NonNANIndex = find(~isnan(OverallAccuracy));

Energy_Final = Energy_Mat.Energy(NonNANIndex, :);
OverallAccuracy_Final = OverallAccuracy(NonNANIndex);

Prediction = RVR_NFolds(Energy_Final, OverallAccuracy_Final', [], 10, 'Scale', 0, '', 0);
for i = 1:20
  Prediction = SVR_NFolds(Energy_Final, OverallAccuracy_Final', [], 10, 'Scale', 1);
  Corr_All(i) = Prediction.Mean_Corr;
  MAE_All(i) = Prediction.Mean_MAE;
end
Corr_Final = mean(Corr_All);
MAE_Final = mean(MAE_All);
save Energy_SVR.mat Corr_Final MAE_Final;



