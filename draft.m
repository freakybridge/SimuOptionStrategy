% clear;
% clc;
% tic;
% 
% import Apps.DataManager;
% import BaseClass.Asset.Asset;
% import EnumType.Product;
% import EnumType.Exchange;
% 
% 
% dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
% dir_rt = "E:\OneDrive\hisdata";
% dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeisbest');
% 
% % dir_tb = 'C:\Users\dell\Desktop\taobao';
% % dir_rt = "D:\OneDrive\hisdata";
% % dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeinmfc');
% 
% 
% dm.Update();
% % dm.DatabaseBackup('C:\Users\freakybridge\Desktop\Backup');
% % dm.DatabaseRestore(dir_rt);
% toc;


ds = BaseClass.DataSource.JoinQuant('18162753893', '1101BXue');


asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Option, '510050', EnumType.Exchange.SSE, 'Symbol', 'SECNAME', ...
    EnumType.Interval.day, 100, EnumType.CallOrPut.Call, 1000, datestr(now()),  datestr(now()));
ins = ds.FetchChain(EnumType.Product.Option, '510050', EnumType.Exchange.SSE, []);