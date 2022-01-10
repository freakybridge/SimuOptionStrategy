% clear;
% clc;
% dm = Apps.DataManger('mss', 'sa', 'bridgeinmfc', 'wind', 'merqh001', '146457');
% instrus = Utility.ReadSheet('D:\OneDrive\hisdata', 'instrument');
% for i = 1 : size(instrus, 1)
%     info = instrus(i, :);
%     opt = BaseClass.Asset.Option("5M", info{1},  info{2},  info{3},  info{7}, [[930, 1130]; [1300, 1500]], info{4}, info{5}, info{6}, info{8}, info{9});
%     fprintf("Loading %s market data, %i/%i, please wait ...\r", info{1}, i, size(instrus, 1));
%     dm.LoadMd(opt, 'C:\Users\dell\Desktop\taobao\final', 'C:\Users\dell\Desktop\taobao');
% end
% 


clear;
clc;
dm = Apps.DataManger('mss', 'sa', 'bridgeinmfc', 'wind', 'merqh001', '146457');
instrus = Utility.ReadSheet('D:\OneDrive\hisdata', 'instrument');
for i = 1 : size(instrus, 1)
    info = instrus(i, :);
    opt = BaseClass.Asset.Option("5M", info{1},  info{2},  info{3},  info{7}, [[930, 1130]; [1300, 1500]], info{4}, info{5}, info{6}, info{8}, info{9});
    fprintf("Loading %s market data, %i/%i, please wait ...\r", info{1}, i, size(instrus, 1));
    
    dm.LoadMdViaTaobaoExcel(opt, 'C:\Users\dell\Desktop\taobao');    
    if (dm.IsDataComplete(opt))
        dm.SaveMd2Database(opt);
        dm.SaveMd2Csv(opt, 'C:\Users\dell\Desktop\taobao\final');
    end
end
