clear;
clc;

import Apps.DataManager;
import BaseClass.Asset.Asset;
import EnumType.Product;
import EnumType.Exchange;


% dm = DataManager('mss', 'sa', 'bridgeisbest');
% dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
% dir_csv = "E:\OneDrive\hisdata";
% dir_rt = "E:\OneDrive\hisdata";

dm = DataManager('mss', 'sa', 'bridgeinmfc');
dir_tb = 'C:\Users\dell\Desktop\taobao';
dir_csv = "D:\OneDrive\hisdata";
dir_rt = "D:\OneDrive\hisdata";

db_ig_lst = {'1D-ETF', '1D-FUTURE-CU-SHFE', '1D-FUTURE-IF-CFFEX', '1D-FUTURE-M-DCE', '1D-FUTURE-SC-INE', '1D-FUTURE-SR-CZCE', '1D-INDEX', '1D-OPTION-510050-SSE', '1MIN-ETF', ...
    '5MIN-OPTION-510050-SSE', '5MIN-OPTION-510300-SSE', 'Calendar', 'Interest', 'master', 'model', 'msdb',  'tempdb', 'INSTRUMENTS'};
tb_ig_lst = {'CodeList', '000188.SH'};
dm.DatabaseBackup('C:\Users\dell\Desktop', db_ig_lst, tb_ig_lst);

% for i = 1 : 2
%     if (i == 1)
%         product = Product.Option;
%         variety = '510300';
%         exchange = Exchange.SSE;
%     else
%         product = Product.Option;
%         variety = '510050';
%         exchange = Exchange.SSE;
%     end
%     
%     
%     instrus = dm.LoadChain(product, variety, exchange, dir_rt);
%     for j = 1 : size(instrus, 1)
%         info = instrus(j, :);
%         opt = Asset.Selector(product, exchange, variety, ...
%             info.SYMBOL{:}, ...
%             info.SEC_NAME{:}, ...
%             '5m', ...
%             info.SIZE, ...
%             info.CALL_OR_PUT{:}, ...
%             info.STRIKE, ...
%             info.START_TRADE_DATE{:}, ...
%             info.END_TRADE_DATE{:});
%         
%         fprintf("Loading [%s.%s]'s quetos, [%i/%i], please wait ...\r", info.SYMBOL{:}, info.EXCHANGE{:}, j, size(instrus, 1));
%         dm.LoadMd(opt, dir_csv, dir_tb);
%     end
% end


