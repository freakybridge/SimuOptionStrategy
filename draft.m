clear;
clc;
tic;

import Apps.DataManager;
import BaseClass.Asset.Asset;
import EnumType.Product;
import EnumType.Exchange;


dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
dir_rt = "E:\OneDrive\hisdata";
dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeisbest');

% dir_tb = 'C:\Users\dell\Desktop\taobao';
% dir_rt = "D:\OneDrive\hisdata";
% dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeinmfc');


% dm.Update();
% dm.DatabaseBackup('C:\Users\dell\Desktop\backup');
dm.DatabaseRestore('C:\Users\freakybridge\Desktop\test');
toc;
