function Prediction = CorrFilter_SVR_Train_Test(Training_Data, Training_Scores, Testing_Data, Testing_Scores, Pre_Method, CoefThreshold, ResultantFolder)
%
% Training_Data:
%           m*n matrix
%           m is the number of subjects
%           n is the number of features
%
% Training_Scores:
%           the continuous variable to be predicted
%
% Pre_Method:
%           'Normalize' or 'Scale'
%
% ResultantFolder:
%           the path of folder storing resultant files
%

if nargin >= 6
    if ~exist(ResultantFolder, 'dir')
        mkdir(ResultantFolder);
    end
end

[~, Feature_Quantity] = size(Training_Data);

Feature_Frequency = zeros(1, Feature_Quantity);

coef = corr(Training_Data, Training_Scores);
coef(find(isnan(coef))) = 0;
RetainID = find(abs(coef) > CoefThreshold);
Training_Data_New = Training_Data(:, RetainID);
Selected_Mask = zeros(1, Feature_Quantity);
Selected_Mask(RetainID) = 1;
Feature_Frequency = Feature_Frequency + Selected_Mask;

% Normalizing
if strcmp(Pre_Method, 'Normalize')
    % Normalizing
    MeanValue = mean(Training_Data_New);
    StandardDeviation = std(Training_Data_New);
    [~, columns_quantity] = size(Training_Data_New);
    for j = 1:columns_quantity
        Training_Data_New(:, j) = (Training_Data_New(:, j) - MeanValue(j)) / StandardDeviation(j);
    end
elseif strcmp(Pre_Method, 'Scale')
    % Scaling to [0 1]
    MinValue = min(Training_Data_New);
    MaxValue = max(Training_Data_New);
    [~, columns_quantity] = size(Training_Data_New);
    for j = 1:columns_quantity
        Training_Data_New(:, j) = (Training_Data_New(:, j) - MinValue(j)) / (MaxValue(j) - MinValue(j));
    end
end

% SVR training
Training_Data_New = double(Training_Data_New);
model = svmtrain(Training_Scores, Training_Data_New,'-s 3 -t 2');
    
Testing_Data_New = Testing_Data(:, RetainID);
Test_Data_Quantity = length(Testing_Scores);
% Normalizing
if strcmp(Pre_Method, 'Normalize')
    % Normalizing
    Testing_Data_New = (Testing_Data_New - repmat(MeanValue, Test_Data_Quantity, 1)) ./ repmat(StandardDeviation, Test_Data_Quantity, 1);
elseif strcmp(Pre_Method, 'Scale')
    % Scale
    Testing_Data_New = (Testing_Data_New - repmat(MinValue, Test_Data_Quantity, 1)) ./ (repmat(MaxValue, Test_Data_Quantity, 1) - repmat(MinValue, Test_Data_Quantity, 1));
end

% predicts
Testing_Data_New = double(Testing_Data_New);
[Predicted_Scores, ~, ~] = svmpredict(Testing_Scores, Testing_Data_New, model);
    
Prediction.Score = Predicted_Scores;
[Prediction.Corr, ~] = corr(Predicted_Scores, Testing_Scores);
Prediction.MAE = mean(abs((Predicted_Scores - Testing_Scores)));
Prediction.Feature_Frequency = Feature_Frequency;
if nargin >= 4
    save([ResultantFolder filesep 'Prediction_res.mat'], 'Prediction');
    disp(['The correlation is ' num2str(Prediction.Corr)]);
    disp(['The MSE is ' num2str(Prediction.MAE)]);
end

