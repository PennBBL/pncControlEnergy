function Prediction = RVR_APredictB(Training_Data, Training_Scores, Testing_Data, Testing_Scores, Covariates_Training, Covariates_Testing, Pre_Method, Weight_Flag, Permutation_Flag, ResultantFolder)
%
% Subject_Data:
%           m*n matrix
%           m is the number of subjects
%           n is the number of features
%
% Subject_Scores:
%           the continuous variable to be predicted
%
% Pre_Method:
%           'Normalize', 'Scale', 'None'
%
% Weight_Flag:
%           whether to compute the weight, 1 or 0
%
% ResultantFolder:
%           the path of folder storing resultant files
%
% RandID:
%           permutation of subjects' ID, for randomly split half
%           set '' if do not need
%

if nargin >= 8
    if ~exist(ResultantFolder, 'dir')
        mkdir(ResultantFolder);
    end
end 
    
[~, Features_Quantity] = size(Training_Data);
if Permutation_Flag
    Permutation_Index = randperm(length(Training_Scores));
    Training_Scores = Training_scores(Permutation_Index);
end

if ~isempty(Covariates_Training)
    [Training_Quantity, Covariates_Quantity] = size(Covariates_Training);
    M = 1;
    for k = 1:Covariates_Quantity
        M = M + term(Covariates_Training(:, k));
    end
    slm = SurfStatLinMod(Training_Data, M);
    
    Training_Data = Training_Data - repmat(slm.coef(1, :), Training_Quantity, 1);
    for k = 1:Covariates_Quantity
        Training_Data = Training_Data - ...
            double(repmat(Covariates_Training(:, k), 1, Features_Quantity)) .* repmat(slm.coef(k + 1, :), Training_Quantity, 1);
    end
end

if strcmp(Pre_Method, 'Normalize')
    % Normalizing
    MeanValue = mean(Training_Data);
    StandardDeviation = std(Training_Data);
    for k = 1:Features_Quantity
        Training_Data(:, k) = (Training_Data(:, k) - MeanValue(k)) / StandardDeviation(k);
    end
elseif strcmp(Pre_Method, 'Scale')
    % Scaling to [0 1]
    MinValue = min(Training_Data);
    MaxValue = max(Training_Data);
    for k = 1:Features_Quantity
        Training_Data(:, k) = (Training_Data(:, k) - MinValue(k)) / (MaxValue(k) - MinValue(k));
    end
end
Training_Data = double(Training_Data);

% Covariate test data
if ~isempty(Covariates_Training)
    [Testing_Quantity, ~] = size(Testing_Data);
    Testing_Data = Testing_Data - repmat(slm.coef(1, :), Testing_Quantity, 1);
    for k = 1:Covariates_Quantity
        Testing_Data = Testing_Data - ...
            double(repmat(Covariates_Testing(:, k), 1, Features_Quantity)) .* repmat(slm.coef(k + 1, :), Testing_Quantity, 1);
    end
end
% Normalize test data
if strcmp(Pre_Method, 'Normalize')
    % Normalizing
    MeanValue_New = repmat(MeanValue, length(Testing_Scores), 1);
    StandardDeviation_New = repmat(StandardDeviation, length(Testing_Scores), 1);
    Testing_Data = (Testing_Data - MeanValue_New) ./ StandardDeviation_New;
elseif strcmp(Pre_Method, 'Scale')
    % Scale
    MaxValue_New = repmat(MaxValue, length(Testing_Scores), 1);
    MinValue_New = repmat(MinValue, length(Testing_Scores), 1);
    Testing_Data = (Testing_Data - MinValue_New) ./ (MaxValue_New - MinValue_New);
end
Testing_Data = double(Testing_Data);
    
% RVR training & predicting
d.train{1} = Training_Data * Training_Data';
d.test{1} = Testing_Data * Training_Data';
d.tr_targets = Training_Scores';
d.use_kernel = 1;
d.pred_type = 'regression';
output = prt_machine_rvr(d, []);
   
Prediction_Score = output.predictions;
Corr = corr(output.predictions, Testing_Scores');
MAE = mean(abs(output.predictions - Testing_Scores'));
    
if nargin >= 9
    save([ResultantFolder filesep 'Prediction.mat'], 'Prediction_Score', 'Corr', 'MAE');
    disp(['The correlation is ' num2str(Corr)]);
    disp(['The MAE is ' num2str(MAE)]);
    % Calculating w
    w_Brain = zeros(1, Features_Quantity);
    for i = 1:length(output.alpha)
        w_Brain = w_Brain + output.alpha(i) * Training_Data(i, :);
    end
    w_Brain = w_Brain / norm(w_Brain);
    save([ResultantFolder filesep 'w_Brain.mat'], 'w_Brain');
end
