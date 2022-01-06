clear;
clc;
dm = Apps.DataManger();
dm.TransferTaobaoExcel('D:\OneDrive\hisdata', 'C:\Users\dell\Desktop\taobao', 'C:\Users\dell\Desktop\taobao\final');


instrus = Utility.ReadSheet('D:\OneDrive\hisdata', 'instrument');
info = instrus(1, :);
opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8});
opt.md = dm.Csv2MarketData('C:\Users\dell\Desktop\taobao\final', opt);


db = BaseClass.DatabaseApi('sa', 'bridgeinmfc');
dm.MarketData2Database(opt, db);


