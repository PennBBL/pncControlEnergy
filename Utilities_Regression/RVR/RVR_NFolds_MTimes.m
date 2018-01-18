
function Prediction = RVR_NFolds_MTimes(Subjects_Data, Subjects_Scores, Covariates, FoldQuantity, Pre_Method, Times, ResultantFile)

Corr = [];
MAE = [];
for i = 1:Times
    Prediction_tmp = RVR_NFolds(Subjects_Data, Subjects_Scores, Covariates, FoldQuantity, Pre_Method, 0, '', 0);
    Corr = [Corr Prediction_tmp.Mean_Corr];
    MAE = [MAE Prediction_tmp.Mean_MAE];
end
Prediction.Mean_Corr = mean(Corr);
Prediction.Mean_MAE = mean(MAE);
if nargin >= 7
    save(ResultantFile, 'Prediction');
end

