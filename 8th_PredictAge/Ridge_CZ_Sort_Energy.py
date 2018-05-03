# -*- coding: utf-8 -*-

import os
import scipy.io as sio
import numpy as np
import time
from sklearn import linear_model
from sklearn import preprocessing
from joblib import Parallel, delayed
  
def Ridge_APredictB_Permutation(Training_Data, Training_Score, Testing_Data, Testing_Score, Times_IDRange, Alpha_Range, NestedCV_FoldQuantity, ResultantFolder, Max_Queued, Queue):

    if not os.path.exists(ResultantFolder):
        os.makedirs(ResultantFolder)

    Subjects_Data_Mat = {'Training_Data': Training_Data, 'Testing_Data': Testing_Data}
    Subjects_Data_Mat_Path = ResultantFolder + '/Subjects_Data.mat'
    sio.savemat(Subjects_Data_Mat_Path, Subjects_Data_Mat)

    Training_Index = np.arange(len(Training_Score))
    RandIndex_Folder = ResultantFolder + '/RandIndex'
    if not os.path.exists(RandIndex_Folder):
        os.makedirs(RandIndex_Folder)

    Finish_File = [];
    Times_IDRange_Todo = np.int64(np.array([]))
    for i in np.arange(len(Times_IDRange)):
        Training_Index_Random = Training_Index
        np.random.shuffle(Training_Index_Random)
        Training_Score_Random = Training_Score[Training_Index_Random]
        RandIndex_Mat = {'Rand_Index': Training_Index_Random, 'Rand_Score': Training_Score_Random}
        sio.savemat(RandIndex_Folder + '/Rand_Index_' + str(Times_IDRange[i]) + '.mat', RandIndex_Mat)

        ResultantFolder_I = ResultantFolder + '/Time_' + str(Times_IDRange[i])
        if not os.path.exists(ResultantFolder_I):
            os.makedirs(ResultantFolder_I)
        if not os.path.exists(ResultantFolder_I + '/APredictB.mat'):
            Times_IDRange_Todo = np.insert(Times_IDRange_Todo, len(Times_IDRange_Todo), Times_IDRange[i])
            Configuration_Mat = {'Subjects_Data_Mat_Path': Subjects_Data_Mat_Path, 'Training_Score_Random': Training_Score_Random, 'Testing_Score': Testing_Score, 'Alpha_Range': Alpha_Range, 'NestedCV_FoldQuantity':NestedCV_FoldQuantity, 'ResultantFolder_I': ResultantFolder_I};
            sio.savemat(ResultantFolder_I + '/Configuration.mat', Configuration_Mat)
            system_cmd = 'python3 -c ' + '\'import sys;\
                sys.path.append("/data/jux/BBL/projects/pncControlEnergy/scripts/Replication_20180418/8th_PredictAge");\
                from Ridge_CZ_Sort_Energy import Ridge_APredictB_Permutation_Sub;\
                import os;\
                import scipy.io as sio;\
                configuration = sio.loadmat("'+ ResultantFolder_I + '/Configuration.mat");\
                Subjects_Data_Mat_Path = configuration["Subjects_Data_Mat_Path"];\
                Training_Score_Random = configuration["Training_Score_Random"];\
                Testing_Score = configuration["Testing_Score"];\
                Alpha_Range = configuration["Alpha_Range"];\
                NestedCV_FoldQuantity = configuration["NestedCV_FoldQuantity"];\
                ResultantFolder_I = configuration["ResultantFolder_I"];\
                Ridge_APredictB_Permutation_Sub(Subjects_Data_Mat_Path[0], Training_Score_Random[0], Testing_Score[0], Alpha_Range[0], NestedCV_FoldQuantity[0][0], ResultantFolder_I[0])\' ';
            system_cmd = system_cmd + ' > "' + ResultantFolder_I + '/perm_' + str(Times_IDRange[i]) + '.log" 2>&1\n'
            Finish_File.append(ResultantFolder_I + '/APredictB.mat')
            script = open(ResultantFolder_I + '/script.sh', 'w')
            script.write(system_cmd)
            script.close()

    if len(Times_IDRange_Todo) > Max_Queued:
        Submit_First_Quantity = Max_Queued
    else:
        Submit_First_Quantity = len(Times_IDRange_Todo)
    for i in np.arange(Submit_First_Quantity):
        ResultantFolder_I = ResultantFolder + '/Time_' + str(Times_IDRange_Todo[i])
        Option = ' -V -o "' + ResultantFolder_I + '/perm_' + str(Times_IDRange_Todo[i]) + '.o" -e"' + ResultantFolder_I + '/perm_' + str(Times_IDRange_Todo[i]) + '.e"';
        os.system('qsub ' + ResultantFolder_I + '/script.sh' + ' -q ' + Queue + ' -N perm_' + str(Times_IDRange_Todo[i]) + Option)
        os.system('sh ' + ResultantFolder_I + '/script.sh');
    if len(Times_IDRange_Todo) > Max_Queued:
        Finished_Quantity = 0;
        while 1:
            for i in np.arange(len(Finish_File)):
                if os.path.exists(Finish_File[i]):
                    Finished_Quantity = Finished_Quantity + 1
                    print(Finish_File[i])
                    del(Finish_File[i]);
                    print(time.strftime('%Y-%m-%d-%H-%M-%S',time.localtime(time.time())))
                    print('Finish quantity = ' + str(Finished_Quantity))
                    time.sleep(8)
                    ResultantFolder_I = ResultantFolder + '/Time_' + str(Times_IDRange_Todo[Max_Queued + Finished_Quantity - 1])
                    Option = ' -V -o "' + ResultantFolder_I + '/perm_' + str(Times_IDRange_Todo[Max_Queued + Finished_Quantity - 1]) + '.o" -e "' + ResultantFolder_I + '/perm_' + str(Times_IDRange_Todo[Max_Queued + Finished_Quantity - 1]) + '.e"';
                    cmd = 'qsub ' + ResultantFolder_I + '/script.sh' + ' -q ' + Queue + ' -N perm_' + str(Times_IDRange_Todo[Max_Queued + Finished_Quantity - 1]) + Option
                    print(cmd)
                    os.system(cmd)
                    os.system('sh ' + ResultantFolder_I + '/script.sh');
                    break
            if len(Finish_File) == 0:
                break

def Ridge_APredictB_Permutation_Sub(Subjects_Data_Mat_Path, Training_Score, Testing_Score, Alpha_Range, NestedCV_FoldQuantity, ResultantFolder):
    data = sio.loadmat(Subjects_Data_Mat_Path)
    Training_Data = data['Training_Data']
    Testing_Data = data['Testing_Data']
    Ridge_APredictB(Training_Data, Training_Score, Testing_Data, Testing_Score, Alpha_Range, NestedCV_FoldQuantity, ResultantFolder)

def Ridge_APredictB(Training_Data, Training_Score, Testing_Data, Testing_Score, Alpha_Range, NestedCV_FoldQuantity, ResultantFolder):

    if not os.path.exists(ResultantFolder):
            os.makedirs(ResultantFolder)

    ResultantFolder_OptimalAlpha = ResultantFolder + '/OptimalAlpha'
    OptimalAlpha_Final = Ridge_OptimalAlpha_OuterKFold(Training_Data, Training_Score, Alpha_Range, NestedCV_FoldQuantity, ResultantFolder_OptimalAlpha, 1)

    Scale = preprocessing.MinMaxScaler()
    Training_Data = Scale.fit_transform(Training_Data)
    Testing_Data = Scale.transform(Testing_Data) 

    clf = linear_model.Ridge(alpha = OptimalAlpha_Final)
    clf.fit(Training_Data, Training_Score)
    Predict_Score = clf.predict(Testing_Data)

    Predict_Corr = np.corrcoef(Predict_Score, Testing_Score)
    Predict_Corr = Predict_Corr[0,1]
    Predict_MAE = np.mean(np.abs(np.subtract(Predict_Score, Testing_Score)))

    Predict_result = {'Test_Score':Testing_Score, 'Predict_Score':Predict_Score, 'Predict_Corr':Predict_Corr, 'Predict_MAE':Predict_MAE}
    sio.savemat(ResultantFolder+'/APredictB.mat', Predict_result)
    return

def Ridge_OptimalAlpha_OuterKFold(Subjects_Data, Subjects_Score, Alpha_Range, Fold_Quantity, ResultantFolder, Parallel_Quantity):

    if not os.path.exists(ResultantFolder):
            os.makedirs(ResultantFolder)
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
    
    Fold_OptimalAlpha = [];
    for j in np.arange(Fold_Quantity):

        Fold_J_Index = np.arange(j, EachFold_Max[j], Fold_Quantity)
        Subjects_Data_test = Subjects_Data[Fold_J_Index, :]
        Subjects_Score_test = Subjects_Score[Fold_J_Index]
        Subjects_Data_train = np.delete(Subjects_Data, Fold_J_Index, axis=0)
        Subjects_Score_train = np.delete(Subjects_Score, Fold_J_Index) 

        Optimal_Alpha, Inner_Corr, Inner_MAE_inv = Ridge_OptimalAlpha_InnerKFold(Subjects_Data_train, Subjects_Score_train, Fold_Quantity, Alpha_Range, ResultantFolder, Parallel_Quantity)
   
        Fold_J_result = {'Index':Sorted_Index[Fold_J_Index], 'Test_Score':Subjects_Score_test, 'Optimal_Alpha':Optimal_Alpha, 'Inner_Corr':Inner_Corr, 'Inner_MAE_inv':Inner_MAE_inv}
        Fold_J_FileName = 'Fold_' + str(j) + '_Score.mat'
        ResultantFile = os.path.join(ResultantFolder, Fold_J_FileName)
        sio.savemat(ResultantFile, Fold_J_result) 

        Fold_OptimalAlpha.append(Optimal_Alpha);   

    # Find the final optimal alpha, the one that was selected the most in the K-fold CV
    OptimalAlpha_Unique = np.unique(Fold_OptimalAlpha);
    SelectedTimes = 0;
    OptimalAlpha_Final = 0;
    for j in np.arange(len(OptimalAlpha_Unique)):
        Index = np.where(Fold_OptimalAlpha == OptimalAlpha_Unique[j]);
        if len(Index[0]) > SelectedTimes:
            SelectedTimes = len(Index[0])
            OptimalAlpha_Final = OptimalAlpha_Unique[j]
        elif len(Index[0]) == SelectedTimes:
            if OptimalAlpha_Unique[j] > OptimalAlpha_Final:
                OptimalAlpha_Final = OptimalAlpha_Unique[j]

    OptimalAlpha_NFold = {'OptimalAlpha_All':Fold_OptimalAlpha, 'OptimalAlpha_Final':OptimalAlpha_Final};
    ResultantFile = os.path.join(ResultantFolder, 'OptimalAlpha_NFold.mat')
    sio.savemat(ResultantFile, OptimalAlpha_NFold)
    return OptimalAlpha_Final;

def Ridge_OptimalAlpha_InnerKFold(Training_Data, Training_Score, Fold_Quantity, Alpha_Range, ResultantFolder, Parallel_Quantity):
    
    Subjects_Quantity = len(Training_Score)
    Sorted_Index = np.argsort(Training_Score)
    Training_Data = Training_Data[Sorted_Index, :]
    Training_Score = Training_Score[Sorted_Index]
    
    Inner_EachFold_Size = np.int(np.fix(np.divide(Subjects_Quantity, Fold_Quantity)))
    MaxSize = Inner_EachFold_Size * Fold_Quantity
    EachFold_Max = np.ones(Fold_Quantity, np.int) * MaxSize
    tmp = np.arange(Fold_Quantity - 1, -1, -1)
    EachFold_Max = EachFold_Max - tmp
    Remain = np.mod(Subjects_Quantity, Fold_Quantity)
    for j in np.arange(Remain):
    	EachFold_Max[j] = EachFold_Max[j] + Fold_Quantity
    
    print(Alpha_Range);
    Inner_Corr = np.zeros((Fold_Quantity, len(Alpha_Range)))
    Inner_MAE_inv = np.zeros((Fold_Quantity, len(Alpha_Range)))
    Alpha_Quantity = len(Alpha_Range)
    for k in np.arange(Fold_Quantity):
        
        Inner_Fold_K_Index = np.arange(k, EachFold_Max[k], Fold_Quantity)
        Inner_Fold_K_Data_test = Training_Data[Inner_Fold_K_Index, :]
        Inner_Fold_K_Score_test = Training_Score[Inner_Fold_K_Index]
        Inner_Fold_K_Data_train = np.delete(Training_Data, Inner_Fold_K_Index, axis=0)
        Inner_Fold_K_Score_train = np.delete(Training_Score, Inner_Fold_K_Index)
        Scale = preprocessing.MinMaxScaler()
        Inner_Fold_K_Data_train = Scale.fit_transform(Inner_Fold_K_Data_train)
        Inner_Fold_K_Data_test = Scale.transform(Inner_Fold_K_Data_test)    
        
        Parallel(n_jobs=Parallel_Quantity,backend="threading")(delayed(Ridge_SubAlpha)(Inner_Fold_K_Data_train, Inner_Fold_K_Score_train, Inner_Fold_K_Data_test, Inner_Fold_K_Score_test, Alpha_Range[l], l, ResultantFolder) for l in np.arange(len(Alpha_Range)))        
        
        for l in np.arange(Alpha_Quantity):
            print(l)
            Fold_l_Mat_Path = ResultantFolder + '/Fold_' + str(l) + '.mat';
            Fold_l_Mat = sio.loadmat(Fold_l_Mat_Path)
            Inner_Corr[k, l] = Fold_l_Mat['Fold_Corr'][0][0]
            Inner_MAE_inv[k, l] = Fold_l_Mat['Fold_MAE_inv']
            os.remove(Fold_l_Mat_Path)
            
        Inner_Corr = np.nan_to_num(Inner_Corr)
    Inner_Corr_Mean = np.mean(Inner_Corr, axis=0)
    Inner_Corr_Mean = (Inner_Corr_Mean - np.mean(Inner_Corr_Mean)) / np.std(Inner_Corr_Mean)
    Inner_MAE_inv_Mean = np.mean(Inner_MAE_inv, axis=0)
    Inner_MAE_inv_Mean = (Inner_MAE_inv_Mean - np.mean(Inner_MAE_inv_Mean)) / np.std(Inner_MAE_inv_Mean)
    Inner_Evaluation = Inner_Corr_Mean + Inner_MAE_inv_Mean
    
    Inner_Evaluation_Mat = {'Inner_Corr':Inner_Corr, 'Inner_MAE_inv':Inner_MAE_inv, 'Inner_Evaluation':Inner_Evaluation}
    sio.savemat(ResultantFolder + '/Inner_Evaluation.mat', Inner_Evaluation_Mat)
    
    Optimal_Alpha_Index = np.argmax(Inner_Evaluation) 
    Optimal_Alpha = Alpha_Range[Optimal_Alpha_Index]
    return (Optimal_Alpha, Inner_Corr, Inner_MAE_inv)

def Ridge_SubAlpha(Training_Data, Training_Score, Testing_Data, Testing_Score, Alpha, Alpha_ID, ResultantFolder):
    clf = linear_model.Ridge(alpha=Alpha)
    clf.fit(Training_Data, Training_Score)
    Predict_Score = clf.predict(Testing_Data)
    Fold_Corr = np.corrcoef(Predict_Score, Testing_Score)
    Fold_Corr = Fold_Corr[0,1]
    Fold_MAE_inv = np.divide(1, np.mean(np.abs(Predict_Score - Testing_Score)))
    Fold_result = {'Fold_Corr': Fold_Corr, 'Fold_MAE_inv':Fold_MAE_inv}
    ResultantFile = ResultantFolder + '/Fold_' + str(Alpha_ID) + '.mat'
    sio.savemat(ResultantFile, Fold_result)
    return;
    
def Ridge_Weight(Subjects_Data, Subjects_Score, CV_Flag, CV_FoldQuantity_or_Alpha, Alpha_Range, ResultantFolder, Parallel_Quantity):
# If CV_Flag == 0, then Alpha_Range will note be used
    if not os.path.exists(ResultantFolder):
        os.makedirs(ResultantFolder)
    
    if CV_Flag:
        # Select optimal alpha using inner fold cross validation
        Optimal_Alpha = Ridge_OptimalAlpha_OuterKFold(Subjects_Data, Subjects_Score, Alpha_Range, CV_FoldQuantity_or_Alpha, ResultantFolder, Parallel_Quantity)
    else:
        Optimal_Alpha = CV_FoldQuantity_or_Alpha

    Scale = preprocessing.MinMaxScaler()
    Subjects_Data = Scale.fit_transform(Subjects_Data)
    clf = linear_model.Ridge(alpha=Optimal_Alpha)
    clf.fit(Subjects_Data, Subjects_Score)
    Weight = clf.coef_ / np.sqrt(np.sum(clf.coef_ **2))
    Weight_result = {'w_Brain':Weight, 'alpha':Optimal_Alpha}
    sio.savemat(ResultantFolder + '/w_Brain.mat', Weight_result)
    return;

def Ridge_Weight_Permutation(Subjects_Data, Subjects_Score, Times_IDRange, CV_Flag, CV_FoldQuantity_or_Alpha, Alpha_Range, ResultantFolder, Parallel_Quantity):

    if not os.path.exists(ResultantFolder):
        os.makedirs(ResultantFolder)

    for i in np.arange(len(Times_IDRange)):
        print(i)
        Subjects_Index_Random = np.arange(len(Subjects_Score))
        np.random.shuffle(Subjects_Index_Random)
        Subjects_Score_random = Subjects_Score[Subjects_Index_Random]
        ResultantFolder_I = ResultantFolder + '/Time_' + str(Times_IDRange[i])
        os.makedirs(ResultantFolder_I)
        Ridge_Weight(Subjects_Data, Subjects_Score_random, CV_Flag, CV_FoldQuantity_or_Alpha, Alpha_Range, ResultantFolder_I, Parallel_Quantity)

    return;
