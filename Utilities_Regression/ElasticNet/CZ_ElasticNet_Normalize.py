# -*- coding: utf-8 -*-

import scipy.io as sio
import numpy as np
import os
from sklearn import linear_model
from sklearn import preprocessing
from joblib import Parallel, delayed

# Alpha_Range = [0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000]
# Max_Queued = 9;
Alpha_Range = np.exp(np.linspace(-6,5,50));
Max_Queued = 50;
  
def ElasticNet_KFold_2_Permutation(Subjects_Data, Subjects_Score, Times_IDRange, Fold_Quantity, InnerCV_Flag, ResultantFolder):
    
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
        ElasticNet_KFold_2(Subjects_Data, Subjects_Score_Random, Fold_Quantity, InnerCV_Flag, ResultantFolder_I)
    
def ElasticNet_KFold_2(Subjects_Data, Subjects_Score, Fold_Quantity, InnerCV_Flag, ResultantFolder):

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
            Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold_2(Subjects_Data_train, Subjects_Score_train, Fold_Quantity, Alpha_Range, ResultantFolder)
            #######################################################################  
        else:
            Optimal_Alpha = 1

        Normalize = preprocessing.StandardScaler() # zero mean, unit variance
        Subjects_Data_train = Normalize.fit_transform(Subjects_Data_train)
        Subjects_Data_test = Normalize.transform(Subjects_Data_test)            

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
            Fold_J_result = {'Index':Fold_J_Index, 'Test_Score':Subjects_Score_test, 'Predict_Score':Fold_J_Score, 'Weight':clf.coef_, 'Corr':Fold_J_Corr, 'MAE':Fold_J_MAE, 'alpha':Optimal_Alpha, 'Inner_Corr':Inner_Corr, 'Inner_MAE_inv':Inner_MAE_inv}
        else:
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
    
def ElasticNet_APredictB_2_Permutation(Training_Data, Training_Score, Testing_Data, Testing_Score, Times_IDRange, CV_Flag, CV_FoldQuantity, ResultantFolder):
    
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
        ElasticNet_APredictB_2(Training_Data, Training_Score_Random, Testing_Data, Testing_Score, CV_Flag, CV_FoldQuantity, ResultantFolder_I)
    
def ElasticNet_APredictB_2(Training_Data, Training_Score, Testing_Data, Testing_Score, CV_Flag, CV_FoldQuantity_or_Alpha, ResultantFolder):
    
    if CV_Flag:
        # Select optimal alpha using inner fold cross validation
        Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold_2(Training_Data, Training_Score, CV_FoldQuantity_or_Alpha, Alpha_Range, ResultantFolder)
    else:
        Optimal_Alpha = CV_FoldQuantity_or_Alpha;

    Normalize = preprocessing.StandardScaler()
    Training_Data = Normalize.fit_transform(Training_Data)
    Testing_Data = Normalize.transform(Testing_Data)  
    
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
    
def ElasticNet_OptimalAlpha_KFold_2(Training_Data, Training_Score, Fold_Quantity, Alpha_Range, ResultantFolder):
    
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
        
        Normalize = preprocessing.StandardScaler()
        Inner_Fold_K_Data_train = Normalize.fit_transform(Inner_Fold_K_Data_train)
        Inner_Fold_K_Data_test = Normalize.transform(Inner_Fold_K_Data_test)    
        
        Parallel(n_jobs=Max_Queued,backend="threading")(delayed(ElasticNet_SubAlpha)(Inner_Fold_K_Data_train, Inner_Fold_K_Score_train, Inner_Fold_K_Data_test, Inner_Fold_K_Score_test, Alpha_Range[l], l, ResultantFolder) for l in np.arange(len(Alpha_Range)))        
        
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
    
    Index_Corr_Positive = np.argwhere(Inner_Corr_Mean > 0);
    if len(Index_Corr_Positive) > 0:
        Evaluation_Para_Selected = Inner_Evaluation_Sum_3Para[Index_Corr_Positive]
        Optimal_Alpha_Index = Index_Corr_Positive[np.argmax(Evaluation_Para_Selected)]
    else:
        Optimal_Alpha_Index = np.argmax(Inner_Evaluation_Sum_3Para) 
    
    Optimal_Alpha = Alpha_Range[Optimal_Alpha_Index]
    return (Optimal_Alpha, Inner_Corr, Inner_MAE_inv)

def ElasticNet_SubAlpha(Training_Data, Training_Score, Testing_Data, Testing_Score, Alpha, Alpha_ID, ResultantFolder):
    clf = linear_model.ElasticNet(l1_ratio=0.5, alpha=Alpha)
    clf.fit(Training_Data, Training_Score)
    Predict_Score = clf.predict(Testing_Data)
    Fold_Corr = np.corrcoef(Predict_Score, Testing_Score)
    Fold_Corr = Fold_Corr[0,1]
    Fold_MAE_inv = np.divide(1, np.mean(np.abs(Predict_Score - Testing_Score)))
    Fold_result = {'Fold_Corr': Fold_Corr, 'Fold_MAE_inv':Fold_MAE_inv}
    ResultantFile = ResultantFolder + '/Fold_' + str(Alpha_ID) + '.mat'
    sio.savemat(ResultantFile, Fold_result)
    
def ElasticNet_Weight(Subjects_Data, Subjects_Score, CV_Flag, CVFoldQuantity_Or_Alpha, ResultantFolder):
# if CV_Flag is 1, CVFoldQuantity_Or_Alpha is the quantity of folds
# if CV_Flag is 0, CVFoldQuantity_Or_Alpha is alpha
    
    if CV_Flag:
        # Select optimal alpha using inner fold cross validation
        Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold_2(Subjects_Data, Subjects_Score, CVFoldQuantity_Or_Alpha, Alpha_Range, ResultantFolder)
    else:
        Optimal_Alpha = CVFoldQuantity_Or_Alpha;
    
    Normalize = preprocessing.StandardScaler()
    Subjects_Data = Normalize.fit_transform(Subjects_Data)
    clf = linear_model.ElasticNet(l1_ratio=0.5,alpha = Optimal_Alpha)
    clf.fit(Subjects_Data, Subjects_Score)
    if CV_Flag:
        Weight_result = {'Weight':clf.coef_, 'Alpha':Optimal_Alpha}
    else:
        Weight_result = {'Weight':clf.coef_}
    sio.savemat(ResultantFolder + '/Weight.mat', Weight_result)
    return;

def ElasticNet_Weight_BootStrap(Subjects_Data, Subjects_Score, CV_Flag, CVFoldQuantity_Or_Alpha, Times_Range, ResultantFolder):
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
            Optimal_Alpha, Inner_Corr, Inner_MAE_inv = ElasticNet_OptimalAlpha_KFold_2(Subjects_Data_Selected, Subjects_Score_Selected, CVFoldQuantity_Or_Alpha, Alpha_Range, ResultantFolder)
        else:
            Optimal_Alpha = CVFoldQuantity_Or_Alpha;
        
        Normalize = preprocessing.StandardScaler()
        Subjects_Data_Selected = Normalize.fit_transform(Subjects_Data_Selected)
        clf = linear_model.ElasticNet(l1_ratio=0.5,alpha = Optimal_Alpha)
        clf.fit(Subjects_Data_Selected, Subjects_Score_Selected)
        if CV_Flag:
            Weight_result = {'Weight':clf.coef_, 'Alpha':Optimal_Alpha}
        else:
            Weight_result = {'Weight':clf.coef_}
        Weight_FileName = 'Weight_' + str(i) + '.mat';
        sio.savemat(os.path.join(ResultantFolder, Weight_FileName), Weight_result)
    return;
