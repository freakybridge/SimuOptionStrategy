clear;
clc;
dm = Apps.DataManger('mss', 'wind');
instrus = Utility.ReadSheet('E:\OneDrive\hisdata', 'instrument');
for i = 1 : size(instrus, 1)
    info = instrus(i, :);
    opt = BaseClass.Asset.Option("5M", info{1},  info{2},  info{3},  info{7}, [[930, 1130]; [1300, 1500]], info{4}, info{5}, info{6}, info{8}, info{9});
    dm.LoadMd(opt, 'C:\Users\freakybridge\Desktop\taobao\final', 'C:\Users\freakybridge\Desktop\taobao');
end
