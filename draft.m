clear;
clc;
tic;

import Apps.DataManager;
import BaseClass.Asset.Asset;


dir_rt = "E:\OneDrive\hisdata";
dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeisbest');

% dir_rt = "D:\OneDrive\hisdata";
% dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeinmfc');


% dm.Update();
% dm.DatabaseBackup('C:\Users\freakybridge\Desktop\test');
dm.DatabaseRestore(dir_rt);
toc;

% dm.PurgeDatabase('1D', '5MIN');

% db_target = {'Fund', 'Future', 'Index', 'Option'};
% dm.DatabaseBackupOldVer(dir_rt, db_target)
% 
% ins = dm.LoadChain(EnumType.Product.Option, '510050', EnumType.Exchange.SSE);
% er = Apps.DataRecorder();
% for i = 1 : height(ins)
%     fprintf('Transferring [%s], %i/%i, please wait ...\r', ins(i, 'SYMBOL').SYMBOL{:}, i, height(ins));
%     opt = BaseClass.Asset.Option.Option.Sample('510050', EnumType.Exchange.SSE, EnumType.Interval.min5, ins(i, :));
%     dm.LoadMdViaTaobaoExcel(opt, 'E:\OneDrive\hisdata\taobao\50ETF期权5分钟数据', 'E:\OneDrive\hisdata\taobao\alter');
%     if (~isempty(opt.md))
%         er.SaveMarketData(opt, dir_rt);
%     end
% end
