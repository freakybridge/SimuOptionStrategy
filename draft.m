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
% % dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
% % dir_rt = "E:\OneDrive\hisdata";
% % dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeisbest');
% 
% dir_tb = 'C:\Users\dell\Desktop\taobao';
% dir_rt = "D:\OneDrive\hisdata";
% dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeinmfc');
% 
% 
% dm.Update();
% % dm.DatabaseBackup('C:\Users\freakybridge\Desktop\test');
% % dm.DatabaseRestore(dir_rt);
% toc;


% wd = BaseClass.DataSource.Wind();
% ifd = BaseClass.DataSource.iFinD('meyqh055', '913742');
% tsh = BaseClass.DataSource.Tushare('c5ccec0957ff2142dc1aaa2d6c34f6db1cf7cc41f718475266f7ad0b');
% 
% 
% pdt = EnumType.Product.Option;
% symb = '10003853';
% exc = EnumType.Exchange.SSE;
% inv = EnumType.Interval.min5;
% ts = '2022-02-07 09:30';
% te = '2022-02-07 15:00';
% 
% [~, md_w] = wd.FetchMarketData(pdt, symb, exc, inv, ts, te);
% [~, md_i] = ifd.FetchMarketData(pdt, symb, exc, inv, ts, te);
% [~, md_t] = tsh.FetchMarketData(pdt, symb, exc, inv, ts, te);
% 
