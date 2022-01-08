clear;
clc;
dm = Apps.DataManger('mss', 'wind');
% dm.TransferTaobaoExcel('D:\OneDrive\hisdata', 'C:\Users\dell\Desktop\taobao', 'C:\Users\dell\Desktop\taobao\final');
dm.TransferTaobaoExcel('E:\OneDrive\hisdata', 'C:\Users\freakybridge\Desktop\taobao', 'C:\Users\freakybridge\Desktop\taobao\final');


% check Csv2Md / Md2Database
instrus = Utility.ReadSheet('E:\OneDrive\hisdata', 'instrument');
info = instrus(1, :);
opt = BaseClass.Asset.Option("5M", info{1},  info{2},  info{3},  info{7}, [[930, 1130]; [1300, 1500]], info{4}, info{5}, info{6}, info{8}, info{9});
dm.Csv2Md('C:\Users\freakybridge\Desktop\taobao\final', opt);
dm.Md2Database("mss", opt);



instrus = Utility.ReadSheet('E:\OneDrive\hisdata', 'instrument');
info = instrus(1, :);
opt = BaseClass.Asset.Option("5M", info{1},  info{2},  info{3},  info{7}, [[930, 1130]; [1300, 1500]], info{4}, info{5}, info{6}, info{8}, info{9});
dm.Database2Md("mss", opt);

