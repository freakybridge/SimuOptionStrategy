clear;
clc;

import Apps.DataManager;
import BaseClass.Asset.Asset;
import EnumType.Product;
import EnumType.Exchange;


% dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
% dir_rt = "E:\OneDrive\hisdata";
% dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeisbest');

dir_tb = 'C:\Users\dell\Desktop\taobao';
dir_rt = "D:\OneDrive\hisdata";
dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeinmfc');


% dm.Update();
% dm.DatabaseBackup('C:\Users\freakybridge\Desktop\Backup');
% dm.DatabaseBackupOldVer('C:\Users\freakybridge\Desktop\Backup');
% dm.DatabaseRestore(dir_rt);


% dm.DatabaseRestore('C:\Users\dell\Desktop\todb');
% dm.DatabaseBackup('C:\Users\dell\Desktop\fromdb');