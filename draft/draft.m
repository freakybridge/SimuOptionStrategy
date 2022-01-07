clear;
clc;
dm = Apps.DataManger();
dm.TransferTaobaoExcel('D:\OneDrive\hisdata', 'C:\Users\dell\Desktop\taobao', 'C:\Users\dell\Desktop\taobao\final');
% dm.TransferTaobaoExcel('E:\OneDrive\hisdata', 'C:\Users\freakybridge\Desktop\taobao', 'C:\Users\freakybridge\Desktop\taobao\final');


instrus = Utility.ReadSheet('D:\OneDrive\hisdata', 'instrument');
info = instrus(1, :);
opt = BaseClass.Asset.Option("5M", info{1},  info{2},  info{3},  info{7}, [[930, 1130]; [1300, 1500]], info{4}, info{5}, info{6}, info{8}, info{9});
opt.md = dm.Csv2Md('C:\Users\dell\Desktop\taobao\final', opt);


db = BaseClass.DatabaseApi('sa', 'bridgeinmfc');
dm.MarketData2Database(opt, db);




ttt = EnumType.Exchange.CFFEX;
aaa = EnumType.Exchange.ToString(ttt);
bbb = EnumType.Exchange.ToEnum("SZ");
EnumType.Exchange("SZ")

ttt = EnumType.Interval.min1;
aaa = EnumType.Interval.ToString(ttt);


ttt = EnumType.Product.Option;
aaa = EnumType.Product.ToString(ttt);

