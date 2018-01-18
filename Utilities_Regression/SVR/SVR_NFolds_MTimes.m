
function Prediction = SVR_NFolds_MTimes(Subjects_Data, Subjects_Scores, Covariates, FoldQuantity, Pre_Method, C_Range, Times, ResultantFile)

Corr = [];
MAE = [];
for i = 1:Times
    Prediction_tmp = SVR_NFolds_CSelect(Subjects_Data, Subjects_Scores, Covariates, FoldQuantity, Pre_Method, C_Range);
    Corr = [Corr Prediction_tmp.Mean_Corr];
    MAE = [MAE Prediction_tmp.Mean_MAE];
end
Prediction.Mean_Corr = mean(Corr);
Prediction.Mean_MAE = mean(MAE);
if nargin >= 8
    save(ResultantFile, 'Prediction');
end

