# -*- coding: utf-8 -*-

import os
import scipy.io as sio
import numpy as np
import time
from sklearn import linear_model
from sklearn import preprocessing
  
Alpha_Range = np.exp2(np.arange(-15,6));

def Lasso_KFold_Permutation(Subjects_Data, Subjects_Score, Times_IDRange, Fold_Quantity, ResultantFolder):
    
    if not os.path.exists(ResultantFolder):
        os.mkdir(ResultantFolder)
    Subjects_Index = np.arange(len(Subjects_Score))
    RandIndex_Folder = ResultantFolder + '/RandIndex'
    if not os.path.exists(RandIndex_Folder):
        os.mkdir(RandIndex_Folder)
    for i in Times_IDRange:
        Subjects_Index_Random = Subjects_Index
        np.random.shuffle(Subjects_Index_Random)
        Subjects_Score_Random = Subjects_Score[Subjects_Index_Random]
        RandIndex_Mat = {'Rand_Index': Subjects_Index_Random, 'Rand_Score': Subjects_Score_Random}
        sio.savemat(RandIndex_Folder + '/Rand_Index_' + str(i) + '.mat', RandIndex_Mat)
        ResultantFolder_I = ResultantFolder + '/Time_' + str(i)
        if not os.path.exists(ResultantFolder_I):
            os.mkdir(ResultantFolder_I)
        Lasso_KFold(Subjects_Data, Subjects_Score_Random, Fold_Quantity, ResultantFolder_I)

def Lasso_KFold_RandSplit_MTimes_AllSubsets(Subjects_Data_Mat_Path, Subjects_Score, SampleSize_Array, Times_SampleResample, Times_NFold, Fold_Quantity, ResultantFolder, Max_Queued, QueueOptions):
    
    Finish_File = []
    Times_IDRange_Todo_Size = np.int64(np.array([]))
    Times_IDRange_Todo_Size_ResampleIndex = np.int64(np.array([]))
    for i in np.arange(len(SampleSize_Array)):
        ResultantFolder_I = os.path.join(ResultantFolder, 'SampleSize_' + str(SampleSize_Array[i]))
        if not os.path.exists(ResultantFolder_I):
            os.mkdir(ResultantFolder_I)
        for j in np.arange(Times_SampleResample):
            if not os.path.exists(ResultantFolder_I + '/Res_' + str(j) + '.mat'):
                Times_IDRange_Todo_Size = np.insert(Times_IDRange_Todo_Size, len(Times_IDRange_Todo_Size), i)
                Times_IDRange_Todo_Size_ResampleIndex = np.insert(Times_IDRange_Todo_Size_ResampleIndex, len(Times_IDRange_Todo_Size_ResampleIndex), j)
                Configuration_Mat = {'Subjects_Data_Mat_Path': Subjects_Data_Mat_Path, 'Subjects_Score': Subjects_Score, 'SampleSize': SampleSize_Array[i], \
                    'Fold_Quantity': Fold_Quantity, 'Times_NFold': Times_NFold, 'Sample_Index': j, 'ResultantFolder_I': ResultantFolder_I};
                sio.savemat(ResultantFolder_I + '/Configuration_' + str(j) + '.mat', Configuration_Mat)
                system_cmd = 'python3 -c ' + '\'import sys;\
                    sys.path.append("/lustre/gaolab/cuizaixu/Utilities_Zaixu/Utilities_Regression/LeastSquares");\
                    from LeastSquares_CZ import Lasso_KFold_RandSplit_MTimes_OneSubset;\
                    import os;\
                    import scipy.io as sio;\
                    configuration = sio.loadmat("' + ResultantFolder_I + '/Configuration_' + str(j) + '.mat");\
                    Subjects_Data_Mat_Path = configuration["Subjects_Data_Mat_Path"];\
                    Subjects_Score = configuration["Subjects_Score"];\
                    SampleSize = configuration["SampleSize"];\
                    Fold_Quantity = configuration["Fold_Quantity"];\
                    Times_NFold = configuration["Times_NFold"];\
                    Sample_Index = configuration["Sample_Index"];\
                    ResultantFolder_I = configuration["ResultantFolder_I"];\
                    Lasso_KFold_RandSplit_MTimes_OneSubset(Subjects_Data_Mat_Path[0], Subjects_Score[0], SampleSize[0][0], Fold_Quantity[0][0], Times_NFold[0][0], Sample_Index[0][0], ResultantFolder_I[0])\' ';
                system_cmd = system_cmd + ' > "' + ResultantFolder_I + '/Lasso_' + str(j) + '.log" 2>&1\n'
                Finish_File.append(ResultantFolder_I + '/Res_' + str(j) + '.mat')
                script = open(ResultantFolder_I + '/script_' + str(j) + '.sh', 'w')  
                script.write(system_cmd)
                script.close()
    
    Jobs_Quantity = len(Finish_File)

    if len(Times_IDRange_Todo_Size) > Max_Queued:
        Submit_Quantity = Max_Queued
    else:
        Submit_Quantity = len(Times_IDRange_Todo_Size)
    for i in np.arange(Submit_Quantity):
        ResultantFolder_I = ResultantFolder + '/SampleSize_' + str(SampleSize_Array[Times_IDRange_Todo_Size[i]])
        Option = ' -V -o "' + ResultantFolder_I + '/prediction_' + str(Times_IDRange_Todo_Size_ResampleIndex[i]) + '.o" -e "' + ResultantFolder_I + '/prediction_' + str(Times_IDRange_Todo_Size_ResampleIndex[i]) + '.e"';
        os.system('qsub ' + ResultantFolder_I + '/script_' + str(Times_IDRange_Todo_Size_ResampleIndex[i]) +'.sh ' + QueueOptions + ' -N prediction_' + str(Times_IDRange_Todo_Size[i]) + '_' + str(Times_IDRange_Todo_Size_ResampleIndex[i]) + Option)
    if len(Times_IDRange_Todo_Size) > Max_Queued:
        Finished_Quantity = 0;
        while 1:
            for i in np.arange(len(Finish_File)):
                if os.path.exists(Finish_File[i]):
                    Finished_Quantity = Finished_Quantity + 1
                    print(Finish_File[i])            
                    del(Finish_File[i])
                    print(time.strftime('%Y-%m-%d-%H-%M-%S',time.localtime(time.time())))
                    print('Finish quantity = ' + str(Finished_Quantity))
                    time.sleep(8)
                    ResultantFolder_I = ResultantFolder + '/SampleSize_' + str(SampleSize_Array[Times_IDRange_Todo_Size[Submit_Quantity]])
                    Option = ' -V -o "' + ResultantFolder_I + '/prediction_' + str(Times_IDRange_Todo_Size_ResampleIndex[Submit_Quantity]) + '.o" -e "' + ResultantFolder_I + '/prediction_' + str(Times_IDRange_Todo_Size_ResampleIndex[Submit_Quantity]) + '.e"';
                    cmd = 'qsub ' + ResultantFolder_I + '/script_' + str(Times_IDRange_Todo_Size_ResampleIndex[Submit_Quantity]) + '.sh ' + QueueOptions + ' -N prediction_' + str(Times_IDRange_Todo_Size[Submit_Quantity]) + '_' + str(Times_IDRange_Todo_Size_ResampleIndex[Submit_Quantity]) + Option
                    # print(cmd)
                    os.system(cmd)
                    Submit_Quantity = Submit_Quantity + 1
                    break
            if Submit_Quantity >= Jobs_Quantity:
                break
            
def Lasso_KFold_RandSplit_MTimes_OneSubset(Subjects_Data_Mat_Path, Subjects_Score, SampleSize, Fold_Quantity, Times, SampleIndex, ResultantFolder):
    
    data = sio.loadmat(Subjects_Data_Mat_Path)
    Subjects_Data = data['Subjects_Data']
    SelectedIDs = np.random.choice(range(len(Subjects_Score)), SampleSize, replace=False)
    Data_Selected = Subjects_Data[SelectedIDs,:]
    Scores_Selected = Subjects_Score[SelectedIDs]
    Mean_Corr_MTimes, Mean_MAE_MTimes, Corr_MTimes, MAE_MTimes = Lasso_KFold_RandSplit_MTimes(Data_Selected, Scores_Selected, Fold_Quantity, Times)
    Res = {'SelectedIDs':SelectedIDs, 'Mean_Corr_MTimes':Mean_Corr_MTimes, 'Mean_MAE_MTimes':Mean_MAE_MTimes, 'Corr_MTimes':Corr_MTimes, 'MAE_MTimes':MAE_MTimes}
    Res_FileName = 'Res_' + str(SampleIndex) + '.mat'
    ResultantFile = os.path.join(ResultantFolder, Res_FileName)
    sio.savemat(ResultantFile, Res)

def Lasso_KFold_RandSplit_MTimes(Subjects_Data, Subjects_Score, Fold_Quantity, Times):

    Corr_MTimes = np.zeros(Times);
    MAE_MTimes = np.zeros(Times);
    for i in np.arange(Times):
        Corr_I, MAE_I = Lasso_KFold_RandSplit(Subjects_Data, Subjects_Score, Fold_Quantity, 1)
        Corr_MTimes[i] = Corr_I
        MAE_MTimes[i] = MAE_I
    Mean_Corr_MTimes = np.mean(Corr_MTimes)
    Mean_MAE_MTimes = np.mean(MAE_MTimes)
    return (Mean_Corr_MTimes, Mean_MAE_MTimes, Corr_MTimes, MAE_MTimes)

def Lasso_KFold_RandSplit(Subjects_Data, Subjects_Score, Fold_Quantity, InnerCV_Flag, Alpha_Value):

    Subjects_Quantity = len(Subjects_Score)
    EachFold_Size = np.int(np.fix(np.divide(Subjects_Quantity, Fold_Quantity)))
    Remain = np.mod(Subjects_Quantity, Fold_Quantity)
    RandIndex = np.arange(Subjects_Quantity)
    np.random.shuffle(RandIndex)
    
    Fold_Corr = [];
    Fold_MAE = [];
    Fold_Weight = [];

    for j in np.arange(Fold_Quantity):

        Fold_J_Index = RandIndex[EachFold_Size * j + np.arange(EachFold_Size)]
        if Remain > j:
            Fold_J_Index = np.insert(Fold_J_Index, len(Fold_J_Index), RandIndex[EachFold_Size * Fold_Quantity + j])

        Subjects_Data_test = Subjects_Data[Fold_J_Index, :]
        Subjects_Score_test = Subjects_Score[Fold_J_Index]
        Subjects_Data_train = np.delete(Subjects_Data, Fold_J_Index, axis=0)
        Subjects_Score_train = np.delete(Subjects_Score, Fold_J_Index) 

        if InnerCV_Flag:
            # Select optimal alpha using inner 3-fold cross validation
            Optimal_Alpha, Inner_Corr, Inner_MAE_inv = Lasso_OptimalAlpha_KFold(Subjects_Data_train, Subjects_Score_train, Fold_Quantity, Alpha_Range)
            #######################################################################  
        else:
            Optimal_Alpha = Alpha_Value
 
        normalize = preprocessing.MinMaxScaler()
        Subjects_Data_train = normalize.fit_transform(Subjects_Data_train)
        Subjects_Data_test = normalize.transform(Subjects_Data_test)

        clf = linear_model.Lasso(alpha = OptimalAlpha) # Select the optimal alpha
        clf.fit(Subjects_Data_train, Subjects_Score_train)
        Fold_J_Score = clf.predict(Subjects_Data_test)

        Fold_J_Corr = np.corrcoef(Fold_J_Score, Subjects_Score_test)
        Fold_J_Corr = Fold_J_Corr[0,1]
        Fold_Corr.append(Fold_J_Corr)
        Fold_J_MAE = np.mean(np.abs(np.subtract(Fold_J_Score,Subjects_Score_test)))
        Fold_MAE.append(Fold_J_MAE)
    
        # Fold_J_result = {'Index':Fold_J_Index, 'Test_Score':Subjects_Score_test, 'Predict_Score':Fold_J_Score, 'Corr':Fold_J_Corr, 'MAE':Fold_J_MAE}
        # Fold_J_FileName = 'Fold_' + str(j) + '_Score.mat'
        # ResultantFile = os.path.join(ResultantFolder, Fold_J_FileName)
        # sio.savemat(ResultantFile, Fold_J_result)

    Fold_Corr = [0 if np.isnan(x) else x for x in Fold_Corr]
    Mean_Corr = np.mean(Fold_Corr)
    Mean_MAE = np.mean(Fold_MAE)
    # Res_NFold = {'Mean_Corr':Mean_Corr, 'Mean_MAE':Mean_MAE};
    # ResultantFile = os.path.join(ResultantFolder, 'Res_NFold.mat')
    # sio.savemat(ResultantFile, Res_NFold)
    return (Mean_Corr, Mean_MAE)  

def Lasso_OptimalAlpha_KFold(Subjects_Data_train, Subjects_Score_train, Fold_Quantity, Alpha_Range)

    Subjects_Quantity = len(Subjects_Score_train)
    EachFold_Size = np.int(np.fix(np.divide(Subjects_Quantity, Fold_Quantity)))
    Remain = np.mod(Subjects_Quantity, Fold_Quantity)
    RandIndex = np.arange(Subjects_Quantity)
    np.random.shuffle(RandIndex)
    
    Inner_Corr = np.zeros((Fold_Quantity, len(Alpha_Range)))
    Inner_MAE_inv = np.zeros((Fold_Quantity, len(Alpha_Range)))
    Alpha_Quantity = len(Alpha_Range)

    for i in np.arange(Alpha_Quantity):
        for j in np.arange(5):
            Corr, MAE = Lasso_KFold_RandSplit(Subjects_Data, Subjects_Score, Fold_Quantity, 0, Alpha_Range[i])
            Inner_Corr[j, i] = Corr
            Inner_MAE_inv[j, i] = np.divide(1, MAE)
    Inner_Corr = np.nan_to_num(Inner_Corr)  

    Inner_Corr_Mean = np.mean(Inner_Corr, axis=0)
    Inner_Corr_Mean_norm = (Inner_Corr_Mean - np.mean(Inner_Corr_Mean)) / np.std(Inner_Corr_Mean)
    Inner_MAE_inv_Mean = np.mean(Inner_MAE_inv, axis=0)
    Inner_MAE_inv_Mean = (Inner_MAE_inv_Mean - np.mean(Inner_MAE_inv_Mean)) / np.std(Inner_MAE_inv_Mean)
    Inner_Evaluation = Inner_Corr_Mean_norm + Inner_MAE_inv_Mean

    Inner_Evaluation_Sum_3Para = np.zeros((1, len(Inner_Evaluation)))
    Inner_Evaluation_Sum_3Para = Inner_Evaluation_Sum_3Para[0]
    Inner_Evaluation_Sum_3Para[0] = Inner_Evaluation[0] + Inner_Evaluation[0] + Inner_Evaluation[1]
    for l in np.arange(len(Inner_Evaluation)-2)+1:
        Inner_Evaluation_Sum_3Para[l] = Inner_Evaluation[l-1] + Inner_Evaluation[l] + Inner_Evaluation[l+1]
    Inner_Evaluation_Sum_3Para[len(Inner_Evaluation)-1] = Inner_Evaluation[len(Inner_Evaluation)-2] + Inner_Evaluation[len(Inner_Evaluation)-1] + Inner_Evaluation[len(Inner_Evaluation)-1]
    
    Index_Corr_Positive = np.argwhere(Inner_Corr_Mean > 0);
    if len(Index_Corr_Positive) > 0:
        Evaluation_Para_Selected = Inner_Evaluation_Sum_3Para[Index_Corr_Positive]
        Optimal_Alpha_Index = Index_Corr_Positive[np.argmax(Evaluation_Para_Selected)]
    else:
        Optimal_Alpha_Index = np.argmax(Inner_Evaluation_Sum_3Para) 
    Optimal_Alpha = Alpha_Range[Optimal_Alpha_Index]

    return (Optimal_Alpha, Inner_Corr, Inner_MAE_inv)
    
def Lasso_KFold(Subjects_Data, Subjects_Score, Fold_Quantity, ResultantFolder):

    if not os.path.exists(ResultantFolder):
        os.mkdir(ResultantFolder)
    Subjects_Quantity = len(Subjects_Score)
    # Sort the subjects score
    Sorted_Index = np.argsort(Subjects_Score)
    Subjects_Data = Subjects_Data[Sorted_Index, :]
    Subjects_Score = Subjects_Score[Sorted_Index]
    
    EachFold_Size = np.int(np.fix(np.divide(Subjects_Quantity, Fold_Quantity)))
    MaxSize = EachFold_Size * Fold_Quantity
    EachFold_Max = np.ones(Fold_Quantity, np.int) * MaxSize
    tmp = np.arange(Fold_Quantity - 1, -1, -1)
    EachFold_Max = EachFold_Max - tmp;
    Remain = np.mod(Subjects_Quantity, Fold_Quantity)
    for j in np.arange(Remain):
        EachFold_Max[j] = EachFold_Max[j] + Fold_Quantity
    
    Fold_Corr = [];
    Fold_MAE = [];
    Fold_Weight = [];
    
    for j in np.arange(Fold_Quantity):
        
        Fold_J_Index = np.arange(j, EachFold_Max[j], Fold_Quantity);	         
        Subjects_Data_test = Subjects_Data[Fold_J_Index,:]
        Subjects_Score_test = Subjects_Score[Fold_J_Index]
        Subjects_Data_train = np.delete(Subjects_Data, Fold_J_Index, axis=0)
        Subjects_Score_train = np.delete(Subjects_Score, Fold_J_Index)    

        normalize = preprocessing.MinMaxScaler()
        Subjects_Data_train = normalize.fit_transform(Subjects_Data_train)
        Subjects_Data_test = normalize.transform(Subjects_Data_test)            

        clf = linear_model.Lasso()
        clf.fit(Subjects_Data_train, Subjects_Score_train)
        Fold_J_Score = clf.predict(Subjects_Data_test)
        
        Fold_J_Corr = np.corrcoef(Fold_J_Score, Subjects_Score_test)
        Fold_J_Corr = Fold_J_Corr[0,1]
        Fold_Corr.append(Fold_J_Corr)
        Fold_J_MAE = np.mean(np.abs(np.subtract(Fold_J_Score,Subjects_Score_test)))
        Fold_MAE.append(Fold_J_MAE)
        Fold_Weight.append(clf.coef_)
    
        Fold_J_result = {'Index':Fold_J_Index, 'Test_Score':Subjects_Score_test, 'Predict_Score':Fold_J_Score, 'Weight':clf.coef_, 'Corr':Fold_J_Corr, 'MAE':Fold_J_MAE}
        Fold_J_FileName = 'Fold_' + str(j) + '_Score.mat'
        ResultantFile = os.path.join(ResultantFolder, Fold_J_FileName)
        sio.savemat(ResultantFile, Fold_J_result)
        
    Fold_Corr = [0 if np.isnan(x) else x for x in Fold_Corr]
    Mean_Corr = np.mean(Fold_Corr)
    Mean_MAE = np.mean(Fold_MAE)
    Weight_Sum = np.transpose([0]*len(clf.coef_))
    Frequency = np.transpose([0]*len(clf.coef_))
    for j in np.arange(Fold_Quantity):
        mask = np.transpose([int(tmp>0) for tmp in Fold_Weight[j]])
        Frequency = Frequency + mask
        Weight_Sum = Weight_Sum + Fold_Weight[j]
    Weight_Average = np.divide(Weight_Sum,Frequency)
    Weight_Average = np.nan_to_num(Weight_Average)
    Res_NFold = {'Mean_Corr':Mean_Corr, 'Mean_MAE':Mean_MAE, 'Weight_Avg':Weight_Average, 'Frequency':Frequency};
    ResultantFile = os.path.join(ResultantFolder, 'Res_NFold.mat')
    sio.savemat(ResultantFile, Res_NFold)
    return
    
def Lasso_APredictB_Permutation(Training_Data, Training_Score, Testing_Data, Testing_Score, Times_IDRange, ResultantFolder):
    
    if not os.path.exists(ResultantFolder):
        os.mkdir(ResultantFolder)
    Training_Index = np.arange(len(Training_Score))
    RandIndex_Folder = ResultantFolder + '/RandIndex'
    if not os.path.exists(RandIndex_Folder):
        os.mkdir(RandIndex_Folder)  
    for i in Times_IDRange:
        Training_Index_Random = Training_Index
        np.random.shuffle(Training_Index_Random)
        Training_Score_Random = Training_Score[Training_Index_Random]
        RandIndex_Mat = {'Rand_Index': Training_Index_Random, 'Rand_Score': Training_Score_Random}
        sio.savemat(RandIndex_Folder + '/Rand_Index_' + str(i) + '.mat', RandIndex_Mat)
        ResultantFolder_I = ResultantFolder + '/Time_' + str(i)
        if not os.path.exists(ResultantFolder_I):
            os.mkdir(ResultantFolder_I)
        Lasso_APredictB(Training_Data, Training_Score_Random, Testing_Data, Testing_Score, ResultantFolder_I)
    
def Lasso_APredictB(Training_Data, Training_Score, Testing_Data, Testing_Score, ResultantFolder):

    normalize = preprocessing.MinMaxScaler()
    Training_Data = normalize.fit_transform(Training_Data)
    Testing_Data = normalize.transform(Testing_Data)  
    
    clf = linear_model.Lasso()
    clf.fit(Training_Data, Training_Score)
    Predict_Score = clf.predict(Testing_Data)

    Predict_Corr = np.corrcoef(Predict_Score, Testing_Score)
    Predict_Corr = Predict_Corr[0,1]
    Predict_MAE = np.mean(np.abs(np.subtract(Predict_Score, Testing_Score)))
    Predict_result = {'Test_Score': Testing_Score, 'Predict_Score': Predict_Score, 'Weight': clf.coef_, 'Predict_Corr': Predict_Corr, 'Predict_MAE': Predict_MAE}
    sio.savemat(ResultantFolder+'/APredictB.mat', Predict_result)
    return
    
def Lasso_Weight(Subjects_Data, Subjects_Score, ResultantFolder):
    
    normalize = preprocessing.MinMaxScaler()
    Subjects_Data = normalize.fit_transform(Subjects_Data)
    clf = linear_model.Lasso()
    clf.fit(Subjects_Data, Subjects_Score)
    Weight_result = {'Weight':clf.coef_}
    sio.savemat(ResultantFolder + '/Weight.mat', Weight_result)
    return;
