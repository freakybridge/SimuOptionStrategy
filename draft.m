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


pdt = EnumType.Product.Option;
symb = '10003853';
exc = EnumType.Exchange.SSE;
inv = EnumType.Interval.min5;
ts = '2022-02-07 09:30';
te = '2022-02-07 15:00';
% wd = BaseClass.DataSource.Wind();
% ifd_01 = BaseClass.DataSource.iFinD('merqh001', '146457');
% ifd_51 = BaseClass.DataSource.iFinD('meyqh051', '266742');
% ifd_55 = BaseClass.DataSource.iFinD('meyqh055', '913742');
% % tsh = BaseClass.DataSource.Tushare('c5ccec0957ff2142dc1aaa2d6c34f6db1cf7cc41f718475266f7ad0b');
ifd_51 = BaseClass.DataSource.iFinD('meyqh051', '266742');
[~, md_i51] = ifd_51.FetchMarketData(pdt, symb, exc, inv, ts, te);
ifd_51.LogOut();
ifd_51 = [];

ifd_55 = BaseClass.DataSource.iFinD('meyqh055', '913742');
[~, md_i55] = ifd_55.FetchMarketData(pdt, symb, exc, inv, ts, te);
ifd_55.LogOut();

ds_j = BaseClass.DataSource.JoinQuant('18162753893', '1101BXue', 'D:\Python\Env\MachineLearn\Scripts\python.exe');
ds_w = BaseClass.DataSource.Wind();
ds_i = BaseClass.DataSource.iFinD('merqh001', '146457');
ds_t = BaseClass.DataSource.Tushare('c5ccec0957ff2142dc1aaa2d6c34f6db1cf7cc41f718475266f7ad0b');

pdt = EnumType.Product.Index;
symb = '000300';
exc = EnumType.Exchange.SSE;
inv = EnumType.Interval.day;
ts = '2022-02-07 09:30';
te = '2022-02-18 15:00';
[~, md_j] = ds_j.FetchMarketData(pdt, symb, exc, inv, ts, te);
[~, md_w] = ds_w.FetchMarketData(pdt, symb, exc, inv, ts, te);
[~, md_i] = ds_i.FetchMarketData(pdt, symb, exc, inv, ts, te);
[~, md_t] = ds_t.FetchMarketData(pdt, symb, exc, inv, ts, te);



% 
% [~, md_w] = wd.FetchMarketData(pdt, symb, exc, inv, ts, te);
[~, md_i_01] = ifd_01.FetchMarketData(pdt, symb, exc, inv, ts, te);
[~, md_i51] = ifd_51.FetchMarketData(pdt, symb, exc, inv, ts, te);
[~, md_i55] = ifd_55.FetchMarketData(pdt, symb, exc, inv, ts, te);
% [~, md_t] = tsh.FetchMarketData(pdt, symb, exc, inv, ts, te);
% 






