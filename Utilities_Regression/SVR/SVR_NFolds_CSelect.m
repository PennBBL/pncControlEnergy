function Prediction = SVR_NFolds_CSelect(Subjects_Data, Subjects_Scores, Covariates, FoldQuantity, Pre_Method, C_Range, ResultantFolder)
%
% Subject_Data:
%           m*n matrix
%           m is the number of subjects
%           n is the number of features
%
% Subject_Scores:
%           the continuous variable to be predicted
%
% Covariates:
%           m*n matrix
%           m is the number of subjects
%           n is the number of covariates
%
% FoldQuantity: 
%           The quantity of folds, 10 or 5 is recommended
%
% Pre_Method:
%           'Normalize', 'Scale', 'None'
%
% ResultantFolder:
%           the path of folder storing resultant files
%

if nargin >= 7
    if ~exist(ResultantFolder, 'dir')
        mkdir(ResultantFolder);
    end
end

[Subjects_Quantity, Features_Quantity] = size(Subjects_Data);
    
% Split into N folds randomly
EachPart_Quantity = fix(Subjects_Quantity / FoldQuantity);
RandID = randperm(Subjects_Quantity);
for j = 1:FoldQuantity
    Origin_ID{j} = RandID([(j - 1) * EachPart_Quantity + 1: j * EachPart_Quantity])';
end
Reamin = mod(Subjects_Quantity, FoldQuantity);
for j = 1:Reamin
    Origin_ID{j} = [Origin_ID{j} ; RandID(FoldQuantity * EachPart_Quantity + j)];
end

for j = 1:FoldQuantity

    disp(['The ' num2str(j) ' fold!']);
    
    Training_data = Subjects_Data;
    Training_scores = Subjects_Scores;
    
    % Select training data and testing data
    test_data = Training_data(Origin_ID{j}, :);
    test_score = Training_scores(Origin_ID{j})';
    Training_data(Origin_ID{j}, :) = [];
    Training_scores(Origin_ID{j}) = [];
    
    if ~isempty(Covariates)
        Covariates_test = Covariates(Origin_ID{j}, :);
        Covariates_training = Covariates;
        Covariates_training(Origin_ID{j}, :) = [];
        [Training_quantity, Covariates_quantity] = size(Covariates_training);
        M = 1;
        for k = 1:Covariates_quantity
            M = M + term(Covariates_training(:, k));
        end
        slm = SurfStatLinMod(Training_data, M);
        
        Training_data = Training_data - repmat(slm.coef(1, :), Training_quantity, 1);
        for k = 1:Covariates_quantity
            Training_data = Training_data - ...
                repmat(Covariates_training(:, k), 1, Feature_Quantity) .* repmat(slm.coef(k + 1, :), Training_quantity, 1);
        end
    end
    
    % Select optimal C
    for i = 1:length(C_Range)
        for j = 1:2
            Prediction_Inner = SVR_NFolds(Training_data, Training_scores, [], 5, 'Scale', C_Range(i));
            Inner_Corr_Array_5Times(j, i) = Prediction_Inner.Mean_Corr;
            Inner_MAE_Array_5Times(j, i) = Prediction_Inner.Mean_MAE;
        end
    end
    Inner_Corr_Array = mean(Inner_Corr_Array_5Times);
    Inner_MAE_Array = mean(Inner_MAE_Array_5Times);
    Inner_MAE_inv_Array = 1./Inner_MAE_Array;
    Inner_Corr_norm_Array = (Inner_Corr_Array - mean(Inner_Corr_Array)) / std(Inner_Corr_Array);
    Inner_MAE_inv_norm_Array = (Inner_MAE_inv_Array - mean(Inner_MAE_inv_Array)) / std(Inner_MAE_inv_Array);
    Inner_Evaluation = Inner_Corr_norm_Array + Inner_MAE_inv_norm_Array;
    
    Inner_Evaluation_Sum_3Para = zeros(1, length(Inner_Evaluation));
    Inner_Evaluation_Sum_3Para(1) = Inner_Evaluation(1) + Inner_Evaluation(1) + Inner_Evaluation(2);
    for i = 2:length(C_Range) - 1
        Inner_Evaluation_Sum_3Para(i) = Inner_Evaluation(i - 1) + Inner_Evaluation(i) + Inner_Evaluation(i + 1);
    end
    Inner_Evaluation_Sum_3Para(end) = Inner_Evaluation(end - 1) + Inner_Evaluation(end) + Inner_Evaluation(end);
    [~, Max_Index] = max(Inner_Evaluation_Sum_3Para);
    C_Optimal = C_Range(Max_Index);
    
    if strcmp(Pre_Method, 'Normalize')
        % Normalizing
        MeanValue = mean(Training_data);
        StandardDeviation = std(Training_data);
        [~, columns_quantity] = size(Training_data);
        for k = 1:columns_quantity
            Training_data(:, k) = (Training_data(:, k) - MeanValue(k)) / StandardDeviation(k);
        end
    elseif strcmp(Pre_Method, 'Scale')
        % Scaling to [0 1]
        MinValue = min(Training_data);
        MaxValue = max(Training_data);
        [~, columns_quantity] = size(Training_data);
        for k = 1:columns_quantity
            Training_data(:, k) = (Training_data(:, k) - MinValue(k)) / (MaxValue(k) - MinValue(k));
        end
    end
    
    % SVR training
    Training_scores = Training_scores';
    Training_data_final = double(Training_data);
    model = svmtrain(Training_scores, Training_data_final, ['-s 3 -t 0 -c ' num2str(C_Optimal)]);
    
    % Covariate test data
    if ~isempty(Covariates)
        [test_quantity, ~] = sieze(test_data);
        test_data = test_data - repmat(slm.coef(1, :), test_quantity, 1);
        for k = 1:Covariates_quantity
            test_data = test_data - ...
                repmat(Covariates_test(:, k), 1, Feature_Quantity) .* repmat(slm.coef(k + 1, :), test_quantity, 1);
        end
    end
    % Normalize test data
    if strcmp(Pre_Method, 'Normalize')
        % Normalizing
        MeanValue_New = repmat(MeanValue, length(test_score), 1);
        StandardDeviation_New = repmat(StandardDeviation, length(test_score), 1);
        test_data = (test_data - MeanValue_New) ./ StandardDeviation_New;
    elseif strcmp(Pre_Method, 'Scale')
        % Scale
        MaxValue_New = repmat(MaxValue, length(test_score), 1);
        MinValue_New = repmat(MinValue, length(test_score), 1);
        test_data = (test_data - MinValue_New) ./ (MaxValue_New - MinValue_New);
    end
    test_data_final = double(test_data);
    % Predict test data
    [Predicted_Scores, ~, ~] = svmpredict(test_score, test_data_final, model);
    Prediction.Origin_ID{j} = Origin_ID{j};
    Prediction.Score{j} = Predicted_Scores;
    Prediction.Corr(j) = corr(Predicted_Scores, test_score);
    Prediction.MAE(j) = mean(abs(Predicted_Scores - test_score));

end

Prediction.Mean_Corr = mean(Prediction.Corr);
Prediction.Mean_MAE = mean(Prediction.MAE);
if nargin >= 7
    save([ResultantFolder filesep 'Prediction.mat'], 'Prediction');
    disp(['The correlation is ' num2str(Prediction.Mean_Corr)]);
    disp(['The MAE is ' num2str(Prediction.Mean_MAE)]);
    % Calculating w
    W_Calculate_SVR(Subjects_Data, Subjects_Scores, Covariates, Pre_Method, ResultantFolder); 
end
