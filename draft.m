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
% % dm.DatabaseBackup('C:\Users\freakybridge\Desktop\Backup');
% % dm.DatabaseRestore(dir_rt);
% toc;


ds = BaseClass.DataSource.JoinQuant('18162753893', '1101BXue');


asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Option, '510050', EnumType.Exchange.SSE, 'Symbol', 'SECNAME', ...
    EnumType.Interval.day, 100, EnumType.CallOrPut.Call, 1000, datestr(now()),  datestr(now()));
ins = ds.FetchChain(EnumType.Product.Option, '510050', EnumType.Exchange.SSE, []);

ts = BaseClass.DataSource.Tushare('c5ccec0957ff2142dc1aaa2d6c34f6db1cf7cc41f718475266f7ad0b');


% df = pro.opt_basic(exchange='DCE', fields='ts_code,name,exercise_type,list_date,delist_date')


            
%             token = 'c5ccec0957ff2142dc1aaa2d6c34f6db1cf7cc41f718475266f7ad0b'; % replace your token here
%             api = pro_api(token);
%             df_basic = api.query('option_basic');
%             disp(df_basic(1:10,:));
%             obj.user = ur;
%             obj.password = pwd;
%             obj.err.code = THS_iFinDLogin(ur, pwd);
%             if (obj.err.code == 0 || obj.err.code == -201)
%                 fprintf('DataSource [%s] Ready.\r', obj.name, obj.user);
%             end