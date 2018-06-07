
function null_model_und_sign_SGE_Sub(Original_Nework_Folder, Null_Network_Folder)
 
  mkdir(Null_Network_Folder); 
  FA_Cell = g_ls([Original_Nework_Folder '/*.mat']);
  for i = 1:399%1:length(FA_Cell)
    tmp = load(FA_Cell{i});
    connectivity = null_model_und_sign(tmp.connectivity);
    [~, FileName, ~] = fileparts(FA_Cell{i});
    save([Null_Network_Folder '/' FileName '.mat'], 'connectivity');
  end
