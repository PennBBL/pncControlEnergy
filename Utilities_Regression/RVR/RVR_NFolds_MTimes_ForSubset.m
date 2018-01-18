
function RVR_NFolds_MTimes_ForSubset(Subjects_Data_Path, Subjects_Scores, SampleSize, Covariates, FoldQuantity, Pre_Method, Times, SampleIndex, ResultantFolder)

tmp = load(Subjects_Data_Path);
FieldName = fieldnames(tmp);
Subjects_Data = tmp.(FieldName{1});

SelectedIDs = randperm(length(Subjects_Scores), SampleSize);
Scores_Selected = Subjects_Scores(SelectedIDs);
Data_Selected = Subjects_Data(SelectedIDs, :);
save([ResultantFolder '/SelectedID_' num2str(SampleIndex) '.mat'], 'SelectedIDs');

Prediction = RVR_NFolds_MTimes(Data_Selected, Scores_Selected', Covariates, FoldQuantity, Pre_Method, Times);
save([ResultantFolder '/Prediction_' num2str(SampleIndex) '.mat'], 'Prediction');