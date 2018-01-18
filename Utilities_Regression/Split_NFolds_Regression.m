
function [Splited_Data Splited_Data_Score Origin_ID] = Split_NFolds_Regression(Subjects_Data, Subjects_Scores, FoldQuantity)

Subjects_Quantity = length(Subjects_Scores);

% Split 
EachPart_Quantity = fix(Subjects_Quantity / FoldQuantity);
RandID = randperm(Subjects_Quantity);
for i = 1:FoldQuantity
    Origin_ID{i} = RandID([(i - 1) * EachPart_Quantity + 1: i * EachPart_Quantity])';
    Splited_Data{i} = Subjects_Data(Origin_ID{i}, :);
    Splited_Data_Score{i} = Subjects_Scores(Origin_ID{i})';
end
Reamin = mod(Subjects_Quantity, FoldQuantity);
for i = 1:Reamin
    Splited_Data{i} = [Splited_Data{i} ; Subjects_Data(RandID(FoldQuantity * EachPart_Quantity + i), :)];
    Origin_ID{i} = [Origin_ID{i} ; RandID(FoldQuantity * EachPart_Quantity + i)]; 
    Splited_Data_Score{i} = [Splited_Data_Score{i} ; Subjects_Scores(RandID(FoldQuantity * EachPart_Quantity + i))];
end
