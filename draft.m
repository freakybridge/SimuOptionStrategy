clear;
clc;

import Apps.DataManager;
import BaseClass.Asset.Asset;
import EnumType.Product;
import EnumType.Exchange;


% dir_tb = 'C:\Users\freakybridge\Desktop\taobao';
% dir_rt = "E:\OneDrive\hisdata";
% dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeisbest');

dir_tb = 'C:\Users\dell\Desktop\taobao';
dir_rt = "D:\OneDrive\hisdata";
dm = DataManager(dir_rt, 'mss', 'sa', 'bridgeinmfc');




% dm.DatabaseBackupOldVer('C:\Users\freakybridge\Desktop\Backup');
dm.DatabaseRestore(dir_rt);


% for i = 1 : 2
%     if (i == 1)
%         product = Product.Option;
%         variety = '510050';
%         exchange = Exchange.SSE;
%     else
%         break;
%         product = Product.Option;
%         variety = '510300';
%         exchange = Exchange.SSE;
%     end
%     
%     
%     instrus = dm.LoadChain(product, variety, exchange);
%     for j = 1 : size(instrus, 1)
%         info = instrus(j, :);
%         opt = Asset.Selector(product, variety, exchange, ...
%             info.SYMBOL{:}, ...
%             info.SEC_NAME{:}, ...
%             EnumType.Interval.min5, ...
%             info.SIZE, ...
%             EnumType.CallOrPut.ToEnum(info.CALL_OR_PUT{:}), ...
%             info.STRIKE, ...
%             info.START_TRADE_DATE{:}, ...
%             info.END_TRADE_DATE{:});
%         
%         fprintf("Loading [%s.%s]'s quetos, [%i/%i], please wait ...\r", info.SYMBOL{:}, info.EXCHANGE{:}, j, size(instrus, 1));
%         dm.LoadMd(opt);
%     end
% end


