
DataFolder = '/data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction';
Energy_Mat = load([DataFolder '/Energy.mat']);
Energy = Energy_Mat.Energy;

Behavior_Mat = load([DataFolder '/Behavior.mat']);
Age_years = Behavior_Mat.Age_years;
TBV = Behavior_Mat.TBV;

EnergyAgeTBV = [Energy Age_years TBV];
save /data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction/EnergyAgeTBV.mat EnergyAgeTBV;

AgeTBV = [Age_years TBV];
save /data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction/AgeTBV.mat AgeTBV;

AgeTBVMeanEnergy = [mean(Energy,2) Age_years TBV];
save /data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction/AgeTBVMeanEnergy.mat AgeTBVMeanEnergy;

load('/data/joy/BBL/projects/pncControlEnergy/data/atlas/Yeo_7system.mat');
FPDM_Index = find(Yeo_7system == 6 | Yeo_7system == 7);
EnergyAgeTBV_FPDM = [Energy(:, FPDM_Index) Age_years TBV];
save /data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction/EnergyAgeTBV_FPDM.mat EnergyAgeTBV_FPDM;
AgeTBVMeanEnergy_FPDM = [mean(Energy(:, FPDM_Index), 2) Age_years TBV];
save /data/joy/BBL/projects/pncControlEnergy/data/ExecFun_Prediction/AgeTBVMeanEnergy_FPDM.mat AgeTBVMeanEnergy_FPDM;
