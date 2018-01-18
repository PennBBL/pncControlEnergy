
function SVR_NFolds_MTimes_ForSubset(Subjects_Data_Path, Subjects_Scores, SampleSize, Covariates, FoldQuantity, Pre_Method, C_Range, Times, SampleIndex, ResultantFolder)

tmp = load(Subjects_Data_Path);
FieldName = fieldnames(tmp);
Subjects_Data = tmp.(FieldName{1});

SelectedIDs = randperm(length(Subjects_Scores), SampleSize);
Data_Selected = Subjects_Data(SelectedIDs, :);
Scores_Selected = Subjects_Scores(SelectedIDs);
save([ResultantFolder '/SelectedID_' num2str(SampleIndex) '.mat'], 'SelectedIDs');

Prediction = SVR_NFolds_MTimes(Data_Selected, Scores_Selected', Covariates, FoldQuantity, Pre_Method, C_Range, Times);
save([ResultantFolder '/Prediction_' num2str(SampleIndex) '.mat'], 'Prediction');