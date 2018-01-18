# -*- coding: utf-8 -*-

import os
import time
import numpy as np
import scipy.io as sio
from sklearn import linear_model
from sklearn import preprocessing
from joblib import Parallel, delayed

Alpha_Range = np.exp(np.linspace(-6,5,20));
# Alpha_Range = np.exp2(np.arange(21)-15) # [2^-15:2^5]
Parallel_Quantity = 20;
# Max_Queued = 256;
  
def ElasticNet_KFold_Sort_AllSubsets(Subjects_Data_Mat_Path, Subjects_Score, SampleSize_Array, Times_SampleResample, Fold_Quantity, ResultantFolder, Max_Queued, QueueOptions):
    
    Finish_File = []
    Times_IDRange_Todo_Size = np.int64(np.array([]))
    Times_IDRange_Todo_Size_ResampleIndex = np.int64(np.array([]))
    for i in np.arange(len(SampleSize_Array)):
        ResultantFolder_I = os.path.join(ResultantFolder, 'SampleSize_' + str(SampleSize_Array[i]))
        if not os.path.exists(ResultantFolder_I):
            os.mkdir(ResultantFolder_I)
        for j in np.arange(Times_SampleResample):
            if not os.path.exists(ResultantFolder_I + '/Prediction_' + str(j) + '.mat'):
                Times_IDRange_Todo_Size = np.insert(Times_IDRange_Todo_Size, len(Times_IDRange_Todo_Size), i)
                Times_IDRange_Todo_Size_ResampleIndex = np.insert(Times_IDRange_Todo_Size_ResampleIndex, len(Times_IDRange_Todo_Size_ResampleIndex), j)
                Configuration_Mat = {'Subjects_Data_Mat_Path': Subjects_Data_Mat_Path, 'Subjects_Score': Subjects_Score, 'SampleSize': SampleSize_Array[i], \
                    'Fold_Quantity': Fold_Quantity, 'Sample_Index': j, 'ResultantFolder_I': ResultantFolder_I};
                sio.savemat(ResultantFolder_I + '/Configuration_' + str(j) + '.mat', Configuration_Mat)
                system_cmd = 'python3 -c ' + '\'import sys;\
                    sys.path.append("/lustre/gaolab/cuizaixu/Utilities_Zaixu/Utilities_Regression/ElasticNet");\
                    from CZ_ElasticNet_ForCompare import ElasticNet_KFold_Sort_OneSubset;\
                    import os;\
                    import scipy.io as sio;\
                    configuration = sio.loadmat("' + ResultantFolder_I + '/Configuration_' + str(j) + '.mat");\
                    Subjects_Data_Mat_Path = configuration["Subjects_Data_Mat_Path"];\
                    Subjects_Score = configuration["Subjects_Score"];\
                    SampleSize = configuration["SampleSize"];\
                    Fold_Quantity = configuration["Fold_Quantity"];\
                    Sample_Index = configuration["Sample_Index"];\
                    ResultantFolder_I = configuration["ResultantFolder_I"];\
                    ElasticNet_KFold_Sort_OneSubset(Subjects_Data_Mat_Path[0], Subjects_Score[0], SampleSize[0][0], Fold_Quantity[0][0], Sample_Index[0][0], ResultantFolder_I[0])\' ';
                system_cmd = system_cmd + ' > "' + ResultantFolder_I + '/ElasticNet_' + str(j) + '.log" 2>&1\n'
                Finish_File.append(ResultantFolder_I + '/Prediction_' + str(j) + '.mat')
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
            
def ElasticNet_KFold_Sort_OneSubset(Subjects_Data_Mat_Path, Subjects_Score, SampleSize, Fold_Quantity, SampleIndex, ResultantFolder):
    
    data = sio.loadmat(Subjects_Data_Mat_Path)
    Subjects_Data = data['Subjects_Data']
    SelectedIDs = np.random.choice(range(len(Subjects_Score)), SampleSize, replace=False)
    Data_Selected = Subjects_Data[SelectedIDs,:]
    Scores_Selected = Subjects_Score[SelectedIDs]
    ResultantFolder_I = ResultantFolder + '/Prediction_' + str(SampleIndex)
    Mean_Corr, Mean_MAE = ElasticNet_KFold_Sort(Data_Selected, Scores_Selected, Fold_Quantity, ResultantFolder_I)
    Res = {'SelectedIDs':SelectedIDs, 'Mean_Corr':Mean_Corr, 'Mean_MAE':Mean_MAE}
    Res_FileName = 'Prediction_' + str(SampleIndex) + '.mat'
    ResultantFile = os.path.join(ResultantFolder, Res_FileName)
    sio.savemat(ResultantFile, Res)

def ElasticNet_KFold_Sort(Subjects_Data, Subjects_Score, Fold_Quantity, ResultantFolder):

    l1_ratio = 0.5
    InnerCV_Flag = 1

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
        
        if InnerCV_Flag:
            # Select optimal alpha using inner 3-fold cross validation
            Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold(Subjects_Data_train, Subjects_Score_train, Fold_Quantity, l1_ratio, Alpha_Range, ResultantFolder, Parallel_Quantity)
            #######################################################################  
        else:
            Optimal_Alpha = 1

        Scale = preprocessing.MinMaxScaler()
        Subjects_Data_train = Scale.fit_transform(Subjects_Data_train)
        Subjects_Data_test = Scale.transform(Subjects_Data_test)            

        clf = linear_model.ElasticNet(l1_ratio=0.5, alpha=Optimal_Alpha)
        clf.fit(Subjects_Data_train, Subjects_Score_train)
        Fold_J_Score = clf.predict(Subjects_Data_test)
        
        Fold_J_Corr = np.corrcoef(Fold_J_Score, Subjects_Score_test)
        Fold_J_Corr = Fold_J_Corr[0,1]
        Fold_Corr.append(Fold_J_Corr)
        Fold_J_MAE = np.mean(np.abs(np.subtract(Fold_J_Score,Subjects_Score_test)))
        Fold_MAE.append(Fold_J_MAE)
        Fold_Weight.append(clf.coef_)
    
        if InnerCV_Flag:
            Fold_J_result = {'Index':Sorted_Index[Fold_J_Index], 'Test_Score':Subjects_Score_test, 'Predict_Score':Fold_J_Score, 'w_Brain':clf.coef_, 'Corr':Fold_J_Corr, 'MAE':Fold_J_MAE, 'alpha':Optimal_Alpha, 'Inner_Corr':Inner_Corr, 'Inner_MAE_inv':Inner_MAE_inv}
        else:
            Fold_J_result = {'Index':Sorted_Index[Fold_J_Index], 'Test_Score':Subjects_Score_test, 'Predict_Score':Fold_J_Score, 'w_Brain':clf.coef_, 'Corr':Fold_J_Corr, 'MAE':Fold_J_MAE}
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
   
    return (Mean_Corr, Mean_MAE)
    
def ElasticNet_APredictB_Permutation(Training_Data, Training_Score, Testing_Data, Testing_Score, Times_IDRange, l1_ratio, CV_Flag, CV_FoldQuantity, ResultantFolder, Parallel_Quantity, Max_Queued, Queue):
    
    if not os.path.exists(ResultantFolder):
        os.mkdir(ResultantFolder)
    
    Subjects_Data_Mat = {'Training_Data': Training_Data, 'Testing_Data': Testing_Data} 
    Subjects_Data_Mat_Path = ResultantFolder + '/Subjects_Data.mat'
    sio.savemat(Subjects_Data_Mat_Path, Subjects_Data_Mat)

    Training_Index = np.arange(len(Training_Score))
    RandIndex_Folder = ResultantFolder + '/RandIndex'
    if not os.path.exists(RandIndex_Folder):
        os.mkdir(RandIndex_Folder)  

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
            os.mkdir(ResultantFolder_I)
        if not os.path.exists(ResultantFolder_I + '/APredictB.mat'):
            Times_IDRange_Todo = np.insert(Times_IDRange_Todo, len(Times_IDRange_Todo), Times_IDRange[i])
            Configuration_Mat = {'Subjects_Data_Mat_Path': Subjects_Data_Mat_Path, 'Training_Score_Random': Training_Score_Random, 'Testing_Score': Testing_Score, \
                'l1_ratio': l1_ratio, 'CV_Flag': CV_Flag, 'CV_FoldQuantity': CV_FoldQuantity, 'ResultantFolder_I': ResultantFolder_I, 'Parallel_Quantity': Parallel_Quantity};
            sio.savemat(ResultantFolder_I + '/Configuration.mat', Configuration_Mat)
            system_cmd = 'python3 -c ' + '\'import sys;\
                sys.path.append("/lustre/shulab/cuizaixu/Utilities_Zaixu/Utilities_Regression/ElasticNet");\
                from ElasticNet_CZ import ElasticNet_APredictB_Permutation_Sub;\
                import os;\
                import scipy.io as sio;\
                configuration = sio.loadmat("'+ ResultantFolder_I + '/Configuration.mat");\
                Subjects_Data_Mat_Path = configuration["Subjects_Data_Mat_Path"];\
                Training_Score_Random = configuration["Training_Score_Random"];\
                Testing_Score = configuration["Testing_Score"];\
                l1_ratio = configuration["l1_ratio"];\
                CV_Flag = configuration["CV_Flag"];\
                CV_FoldQuantity = configuration["CV_FoldQuantity"];\
                ResultantFolder_I = configuration["ResultantFolder_I"];\
                Parallel_Quantity = configuration["Parallel_Quantity"];\
                ElasticNet_APredictB_Permutation_Sub(Subjects_Data_Mat_Path[0], Training_Score_Random[0], Testing_Score[0], l1_ratio[0][0], CV_Flag[0][0], CV_FoldQuantity[0][0], ResultantFolder_I[0], Parallel_Quantity[0][0])\' ';
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
                    # print(cmd)
                    os.system(cmd)
                    break
            if len(Finish_File) == 0:
                break

def ElasticNet_APredictB_Permutation_Sub(Subjects_Data_Mat_Path, Training_Score, Testing_Score, l1_ratio, CV_Flag, CV_FoldQuantity, ResultantFolder, Parallel_Quantity):
    data = sio.loadmat(Subjects_Data_Mat_Path)
    Training_Data = data['Training_Data']
    Testing_Data = data['Testing_Data']
    ElasticNet_APredictB(Training_Data, Training_Score, Testing_Data, Testing_Score, l1_ratio, CV_Flag, CV_FoldQuantity, ResultantFolder, Parallel_Quantity)
   
def ElasticNet_APredictB(Training_Data, Training_Score, Testing_Data, Testing_Score, l1_ratio, CV_Flag, CV_FoldQuantity_or_Alpha, ResultantFolder, Parallel_Quantity):
    
    if CV_Flag:
        # Select optimal alpha using inner fold cross validation
        Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold(Training_Data, Training_Score, CV_FoldQuantity_or_Alpha, l1_ratio, Alpha_Range, ResultantFolder, Parallel_Quantity)
    else:
        Optimal_Alpha = CV_FoldQuantity_or_Alpha;

    Scale = preprocessing.MinMaxScaler()
    Training_Data = Scale.fit_transform(Training_Data)
    Testing_Data = Scale.transform(Testing_Data)  
    
    clf = linear_model.ElasticNet(l1_ratio=0.5, alpha=Optimal_Alpha)
    clf.fit(Training_Data, Training_Score)
    Predict_Score = clf.predict(Testing_Data)

    Predict_Corr = np.corrcoef(Predict_Score, Testing_Score)
    Predict_Corr = Predict_Corr[0,1]
    Predict_MAE = np.mean(np.abs(np.subtract(Predict_Score, Testing_Score)))
    if CV_Flag:
        Predict_result = {'Test_Score':Testing_Score, 'Predict_Score':Predict_Score, 'Weight':clf.coef_, 'Predict_Corr':Predict_Corr, 'Predict_MAE':Predict_MAE, 'alpha':Optimal_Alpha, 'Inner_Corr':Inner_Corr, 'Inner_MAE_inv':Inner_MAE_inv}
    else:
        Predict_result = {'Test_Score':Testing_Score, 'Predict_Score':Predict_Score, 'Weight':clf.coef_, 'Predict_Corr':Predict_Corr, 'Predict_MAE':Predict_MAE}
    sio.savemat(ResultantFolder+'/APredictB.mat', Predict_result)
    return
    
def ElasticNet_OptimalAlpha_KFold(Training_Data, Training_Score, Fold_Quantity, l1_ratio, Alpha_Range, ResultantFolder, Parallel_Quantity):
    
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
        
        Parallel(n_jobs=Parallel_Quantity,backend="threading")(delayed(ElasticNet_SubAlpha)(Inner_Fold_K_Data_train, Inner_Fold_K_Score_train, Inner_Fold_K_Data_test, Inner_Fold_K_Score_test, l1_ratio, Alpha_Range[l], l, ResultantFolder) for l in np.arange(len(Alpha_Range)))        
        
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
    
    Inner_Evaluation_Sum_3Para = np.zeros((1, len(Inner_Evaluation)))
    Inner_Evaluation_Sum_3Para = Inner_Evaluation_Sum_3Para[0]
    Inner_Evaluation_Sum_3Para[0] = Inner_Evaluation[0] + Inner_Evaluation[0] + Inner_Evaluation[1]
    for l in np.arange(len(Inner_Evaluation)-2)+1:
        Inner_Evaluation_Sum_3Para[l] = Inner_Evaluation[l-1] + Inner_Evaluation[l] + Inner_Evaluation[l+1]
    Inner_Evaluation_Sum_3Para[len(Inner_Evaluation)-1] = Inner_Evaluation[len(Inner_Evaluation)-2] + Inner_Evaluation[len(Inner_Evaluation)-1] + Inner_Evaluation[len(Inner_Evaluation)-1]

    Inner_Evaluation_Mat = {'Inner_Corr':Inner_Corr, 'Inner_MAE_inv':Inner_MAE_inv, 'Inner_Evaluation':Inner_Evaluation, 'Inner_Evaluation_Sum_3Para':Inner_Evaluation_Sum_3Para}
    sio.savemat(ResultantFolder + '/Inner_Evaluation.mat', Inner_Evaluation_Mat)
    
    ##################################################################
    Index_Corr_Positive = np.argwhere(Inner_Corr_Mean > 0);   # this is not needed, as corr were normalized, thus with negative value
                                                              # We should use Optimal_Alpha_Index = np.argmax(Inner_Evaluation_Sum_3Para)
                                                              # directly in this part
    if len(Index_Corr_Positive) > 0:
        Evaluation_Para_Selected = Inner_Evaluation_Sum_3Para[Index_Corr_Positive]
        Optimal_Alpha_Index = Index_Corr_Positive[np.argmax(Evaluation_Para_Selected)]
    else:
        Optimal_Alpha_Index = np.argmax(Inner_Evaluation_Sum_3Para) 
    ##################################################################
    
    Optimal_Alpha = Alpha_Range[Optimal_Alpha_Index]
    return (Optimal_Alpha, Inner_Corr, Inner_MAE_inv)

def ElasticNet_SubAlpha(Training_Data, Training_Score, Testing_Data, Testing_Score, l1_ratio, Alpha, Alpha_ID, ResultantFolder):
    clf = linear_model.ElasticNet(l1_ratio=l1_ratio, alpha=Alpha)
    clf.fit(Training_Data, Training_Score)
    Predict_Score = clf.predict(Testing_Data)
    Fold_Corr = np.corrcoef(Predict_Score, Testing_Score)
    Fold_Corr = Fold_Corr[0,1]
    Fold_MAE_inv = np.divide(1, np.mean(np.abs(Predict_Score - Testing_Score)))
    Fold_result = {'Fold_Corr': Fold_Corr, 'Fold_MAE_inv':Fold_MAE_inv}
    ResultantFile = ResultantFolder + '/Fold_' + str(Alpha_ID) + '.mat'
    sio.savemat(ResultantFile, Fold_result)
    
def ElasticNet_Weight(Subjects_Data, Subjects_Score, l1_ratio, CV_Flag, CVFoldQuantity_Or_Alpha, ResultantFolder):
# if CV_Flag is 1, CVFoldQuantity_Or_Alpha is the quantity of folds
# if CV_Flag is 0, CVFoldQuantity_Or_Alpha is alpha

    if not os.path.exists(ResultantFolder):
        os.mkdir(ResultantFolder)

    if CV_Flag:
        # Select optimal alpha using inner fold cross validation
        Parallel_Quantity = 30
        Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold(Subjects_Data, Subjects_Score, CVFoldQuantity_Or_Alpha, l1_ratio, Alpha_Range, ResultantFolder, Parallel_Quantity)
    else:
        Optimal_Alpha = CVFoldQuantity_Or_Alpha;
    
    Scale = preprocessing.MinMaxScaler()
    Subjects_Data = Scale.fit_transform(Subjects_Data)
    clf = linear_model.ElasticNet(l1_ratio=0.5,alpha = Optimal_Alpha)
    clf.fit(Subjects_Data, Subjects_Score)
    if CV_Flag:
        Weight_result = {'Weight':clf.coef_, 'Alpha':Optimal_Alpha}
    else:
        Weight_result = {'Weight':clf.coef_}
    sio.savemat(ResultantFolder + '/Weight.mat', Weight_result)
    return;

def ElasticNet_Weight_BootStrap(Subjects_Data, Subjects_Score, l1_ratio, CV_Flag, CVFoldQuantity_Or_Alpha, Times_Range, ResultantFolder):
# if CV_Flag is 1, CVFoldQuantity_Or_Alpha is the quantity of folds
# if CV_Flag is 0, CVFoldQuantity_Or_Alpha is alpha
    
    for i in Times_Range:
        
        print(i)
        Subjects_Index_Random = np.arange(len(Subjects_Score));
        np.random.shuffle(Subjects_Index_Random)
        SelectedIndex = Subjects_Index_Random[0:np.round(len(Subjects_Score)*0.8)]
        Subjects_Data_Selected = Subjects_Data[SelectedIndex, :]
        Subjects_Score_Selected = Subjects_Score[SelectedIndex]
    
        if CV_Flag:
            # Select optimal alpha using inner fold cross validation
            Parallel_Quantity = 30
            Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold(Subjects_Data_Selected, Subjects_Score_Selected, CVFoldQuantity_Or_Alpha, l1_ratio, Alpha_Range, ResultantFolder, Parallel_Quantity)
        else:
            Optimal_Alpha = CVFoldQuantity_Or_Alpha;
        
        Scale = preprocessing.MinMaxScaler()
        Subjects_Data_Selected = Scale.fit_transform(Subjects_Data_Selected)
        clf = linear_model.ElasticNet(l1_ratio=0.5,alpha = Optimal_Alpha)
        clf.fit(Subjects_Data_Selected, Subjects_Score_Selected)
        if CV_Flag:
            Weight_result = {'w_Brain':clf.coef_, 'Alpha':Optimal_Alpha}
        else:
            Weight_result = {'w_Brain':clf.coef_}
        Weight_FileName = 'w_Brain_' + str(i) + '.mat';
        sio.savemat(os.path.join(ResultantFolder, Weight_FileName), Weight_result)
    return;

def ElasticNet_Weight_L2(Subjects_Data, Subjects_Score, CV_Flag, CVFoldQuantity_Or_Alpha, ResultantFolder):

    if not os.path.exists(ResultantFolder):
        os.mkdir(ResultantFolder)
    l1_ratio = 0
    if CV_Flag:
        # Select optimal alpha using inner fold cross validation
        Parallel_Quantity = 30
        Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold(Subjects_Data, Subjects_Score, CVFoldQuantity_Or_Alpha, l1_ratio, Alpha_Range, ResultantFolder, Parallel_Quantity)
    else:
        Optimal_Alpha = CVFoldQuantity_Or_Alpha;
    
    Scale = preprocessing.MinMaxScaler()
    Subjects_Data = Scale.fit_transform(Subjects_Data)
    clf = linear_model.ElasticNet(l1_ratio = l1_ratio,alpha = Optimal_Alpha)
    clf.fit(Subjects_Data, Subjects_Score)
    if CV_Flag:
        Weight_result = {'w_Brain':clf.coef_, 'Alpha':Optimal_Alpha}
    else:
        Weight_result = {'w_Brain':clf.coef_}
    sio.savemat(ResultantFolder + '/w_Brain.mat', Weight_result)
    return;

def ElasticNet_Weight_L2_Permutation(Subjects_Data, Subjects_Score, Times_IDRange, Alpha, ResultantFolder):
        
    Parallel_Quantity = 60
    if not os.path.exists(ResultantFolder):
        os.mkdir(ResultantFolder)
    Subjects_Index = np.arange(len(Subjects_Score))
    RangeQuantity = np.int64(np.fix(np.divide(len(Times_IDRange), Parallel_Quantity)))
    Remain_Jobs = np.int64(np.mod(len(Times_IDRange), Parallel_Quantity))
    if Remain_Jobs:
        RangeQuantity = RangeQuantity + 1
    for i in np.arange(RangeQuantity):
        if Remain_Jobs and i==RangeQuantity-1:
            Jobs_Quantity = Remain_Jobs
        else:
            Jobs_Quantity = Parallel_Quantity
        Subjects_Index_Random = np.zeros((len(Subjects_Score), Jobs_Quantity))
        Subjects_Score_Random = np.zeros((len(Subjects_Score), Jobs_Quantity))
        for j in np.arange(Jobs_Quantity):
            Index_Random_Tmp = Subjects_Index
            np.random.shuffle(Index_Random_Tmp)
            Subjects_Index_Random[:, j] = Index_Random_Tmp
            Subjects_Score_Random[:, j] = Subjects_Score[Index_Random_Tmp]
        # Create the resultant folder
        ResultantFolder_I = [ResultantFolder + '/Time_' + str(Times_IDRange[i * Parallel_Quantity])]
        if not os.path.exists(ResultantFolder_I[0]):
            os.mkdir(ResultantFolder_I[0])
        RandIndex_Mat = {'Rand_Index': Subjects_Index_Random[:, 0], 'Rand_Score': Subjects_Score_Random[:, 0]}
        sio.savemat(ResultantFolder_I[0] + '/Rand_Index.mat', RandIndex_Mat)
        for j in np.arange(Jobs_Quantity - 1) + 1:
            print(j)
            ResultantFolder_I.append(ResultantFolder + '/Time_' + str(Times_IDRange[j + i * Parallel_Quantity]))
            if not os.path.exists(ResultantFolder_I[j]):
                os.mkdir(ResultantFolder_I[j])
            RandIndex_Mat = {'Rand_Index': Subjects_Index_Random[:, j], 'Rand_Score': Subjects_Score_Random[:, j]}
            sio.savemat(ResultantFolder_I[j] + '/Rand_Index.mat', RandIndex_Mat)
        # Running the program in parallel
        Parallel(n_jobs=Parallel_Quantity)(delayed(ElasticNet_Weight_L2)(Subjects_Data, Subjects_Score_Random[:, l], 0, Alpha, ResultantFolder_I[l]) for l in np.arange(Jobs_Quantity))      
        
        
  
