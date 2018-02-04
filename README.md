# pncControlEnergy

Run the codes according to the order:

1st_CopyMatrices: Copy streamline count matrices (codes are Graham's)

2nd_Matrix_Extraction_Remove_BrainStem.m: Matlab code to remove the brain stem from the matrix, so the matrix will be 233*233

3rd_Extract_Activation.R: R code to extract average brain extraction, which will be the target state of control analysis

4th_Energy_Calculation: Matlab code to calculate the the control energy
    1. EnergyCal_SC_All0Initial_ActivationTarget: (Initial: all 0; Target: activation)
    2. EnergyCal_SC_All0Initial_ActivationTarget_VaryRho: (Initial: all 0; Target: activation; Rho: 0.1, 0.2, 0.5, 0.8, 2, 5, 8, 10)
    3. EnergyCal_SC_All0Initial_ActivationTarget_VaryT: (Initialal: all 0; Target: activation; T: 0.1, 0.2, 0.5, 0.8, 2, 5, 8, 10)
    4. EnergyCal_SC_All0Initial_FP1Target: (Initialal: all 0; Target: FP 1)
    5. EnergyCal_SC_All0Initial_Visual1Target: (Initialal: all 0; Target: Visual 1)
    6. EnergyCal_SC_All0Initial_Motor1Target: (Initialal: all 0; Target: Motor 1)
    
5th_Extract_Behavior.R: Extract behavior data for gam analysis. In the forth step, a matrix of energy (944*233) will output. Here, make
    sure the subjects order of behavior is the same of the oder of energy values.
    
6th_Energy_Effects.R: All the statistical analysis in the paper.
    1. Visualize the energy for each Yeo system
    2. Age effect of the whole brain average energy
    3. Age effect of nodal energy
    4. Age effect of Yeo system average energy
    5. Cognition effect of whole brain average energy (Only accuracy metrics: overall accuracy, F1ExecCompResAccuracy, F2SocialCogAccuracy,
       F3MemoryAccuracy)
    6. Cognition effect of nodal energy (Only F1ExecCompResAccuracy)
    7. Age effect and Cognition effect of distance metric
    8. Correlation between energy and activation at nodal level (between energy and activation, energy and abs(activation))
    9. Specificity of age effect (look at if there is age effect on whole brain average energy if use visual 1 or motor 1 as target state)
    
7th_Vary_Rho_T.R: Vary rho and T parameters to see whether the age effects still exist. The range of both rho and T is 
    [0.1 0.2 0.5 0.8 1 2 5 8 10].
    
g_ls.m is a funtion that will be used in the Maltab scripts here.
PSOM (http://psom.simexp-lab.org/) is used for parallelization when calculating all subjects' energy metrics.
I recommend to set path /data/jux/BBL/projects/pncControlEnergy/scripts/MatlabToolbox/PANDA_1.3.1_64.
g_ls.m and PSOM are included in this folder.
