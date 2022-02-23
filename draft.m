clear;
clc;
tic;

import Apps.DataManager;
import BaseClass.Asset.Asset;


dir_rt = "E:\OneDrive\hisdata";
dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeisbest');

% dir_rt = "D:\OneDrive\hisdata";
% dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeinmfc');


% dm.Update();
% dm.DatabaseBackup('C:\Users\freakybridge\Desktop\test');
% dm.DatabaseRestore('D:\OneDrive\hisdata\test');
toc;

% dm.PurgeDatabase('1D', '5MIN');

db_target = {'Fund', 'Future', 'Index', 'Option'};
dm.DatabaseBackupOldVer('C:\Users\freakybridge\Desktop\test', db_target)
