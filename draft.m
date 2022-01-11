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
dm = Apps.DataManager('mss', 'sa', 'bridgeinmfc', 'wind', 'merqh001', '146457');
dir_tb = 'C:\Users\dell\Desktop\taobao';
dir_csv = 'C:\Users\dell\Desktop\taobao\final';


instrus = Utility.ReadSheet('D:\OneDrive\hisdata', 'instrument');
for i = 1 : size(instrus, 1)
    info = instrus(i, :);
    opt = BaseClass.Asset.Option.Instance.SSE_510050(info{1}, info{2}, info{4}, info{9}, '5m', 'abc ', info{5}, info{6}, info{8}, info{9});
    fprintf("Loading %s market data, %i/%i, please wait ...\r", info{1}, i, size(instrus, 1));
    
%     dm.LoadMd(opt, dir_csv, dir_tb);
    dm.LoadMdViaCsv(opt, dir_csv);
    if (~dm.IsMdComplete(opt))
        dm.LoadMdViaTaobaoExcel(opt, dir_tb);
        if (dm.IsMdComplete(opt))
            dm.SaveMd2Csv(opt, dir_csv);
        end
    end
end


% tmp = dm.LoadOptChainViaExcel("510050", "SSE", "D:\OneDrive\hisdata");
% dm.SaveOptChain2Db("510050", "SSE", tmp);
% tmp = dm.LoadOptChainViaDb("510050", "SSE");
% tmp2 = dm.LoadOptChainViaDb("510300", "SSE");
% 
% 
% tmp = dm.LoadOptChainViaExcel("510300", "SSE", "D:\OneDrive\hisdata");
% dm.SaveOptChain2Db("510300", "SSE", tmp);
tmp = dm.LoadOptChain("510050", "SSE", "D:\OneDrive\hisdata");
