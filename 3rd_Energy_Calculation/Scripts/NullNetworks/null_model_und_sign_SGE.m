
MatrixFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/matrices_withoutBrainStem';
Original_Nework_Folder = [MatrixFolder '/FA'];
Null_Network_Folder = [MatrixFolder '/FA_NullNetworks'];

for i = 21:100
  ResultantFolder_I = [Null_Network_Folder '/NullNetwork_' num2str(i, '%03d')];
  Job_Name = ['NullNetwork_' num2str(i, '%03d')];
  pipeline.(Job_Name).command = 'null_model_und_sign_SGE_Sub(opt.para1, opt.para2)';
  pipeline.(Job_Name).opt.para1 = Original_Nework_Folder;
  pipeline.(Job_Name).opt.para2 = ResultantFolder_I;
end

psom_gb_vars
Pipeline_opt.mode = 'qsub';
Pipeline_opt.qsub_options = '-q all.q';
Pipeline_opt.mode_pipeline_manager = 'batch';
Pipeline_opt.max_queued = 1000;
Pipeline_opt.flag_verbose = 1;
Pipeline_opt.flag_pause = 0;
Pipeline_opt.path_logs = [Null_Network_Folder '/logs2'];

psom_run_pipeline(pipeline, Pipeline_opt);
