clear;
clc;
tic;

import Apps.DataManager;
import BaseClass.Asset.Asset;


% dir_rt = "E:\OneDrive\hisdata";
% dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeisbest');

dir_rt = "D:\OneDrive\hisdata";
dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeinmfc');


% dm.Update();
% dm.DatabaseBackup('C:\Users\freakybridge\Desktop\test');
% dm.DatabaseRestore(dir_rt);
toc;



db_target = {'Fund', 'Future', 'Index', 'Option'};
dm.DatabaseBackupOldVer('C:\Users\dell\Desktop\test', db_target)
