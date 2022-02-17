% DataManager / DatabaseBackup
% v1.3.0.20220113.beta
%      1.首次加入
function DatabaseBackup(obj, dir_sav)
% fetch all database
db_ins = 'INSTRUMENTS';
db_calendar = 'CALENDAR';
dbs = FetchAllDatabase(obj, db_ins, db_calendar);

% backup by database
for i = 1 : length(dbs)
    fprintf(2, 'Backuping progress [%i/%i], please wait ...\r', i ,length(dbs));
    tbs = obj.db.FetchAllTables(dbs{i});
    switch dbs{i}
        case db_calendar
            BackupCalendar(obj, dir_sav);

        case db_ins
            BackupInstruments(obj, tbs, dir_sav);

        otherwise
            BackupAsset(obj, dbs{i}, tbs, dir_sav);
    end
end
end

% fetch call database
function dbs = FetchAllDatabase(obj, db_ins, db_cal)
dbs = obj.db.FetchAllDbs();
for i = length(dbs) : -1 : 1
    this = dbs{i};
    if (strcmp(this, db_ins) || strcmp(this, db_cal))
        continue;
    else
        loc = strfind(this, '-');
        try
            EnumType.Interval.ToEnum(this(1 : loc(1) - 1));
            continue;
        catch
            dbs(i) = [];
        end
    end
end
end

% backup calendar database
function BackupCalendar(obj, dir_sav)
fprintf('Backuping [Calendar], please wait ...\r');
cal = obj.db.LoadCalendar();
obj.dr.SaveCalendar(cal, dir_sav);
end

% backup instruments
function BackupInstruments(obj, tbs, dir_sav)
for i = 1 : length(tbs)
    this = tbs{i};
    loc = strfind(this, '-');
    try
        product = EnumType.Product.ToEnum(this(1 : loc(1) - 1));
        variety = this(loc(1) + 1 : loc(2) - 1);
        exchange = EnumType.Exchange.ToEnum(this(loc(2) + 1 : end));
        fprintf('Backuping [Instruments]-[%s], please wait ...\r', this);
    catch
        fprintf(2, 'Backuping Error, unrecognised table [%s], please check !\r', this);
        continue;
    end

    ins = obj.db.LoadChain(product, variety, exchange);
    obj.dr.SaveChain(product, variety, exchange, ins, dir_sav);
end
end

% backup assets
function BackupAsset(obj, db, tbs, dir_sav)
% determin interval & product
loc = strfind(db, '-');
switch length(loc)
    case 1
        inv = EnumType.Interval.ToEnum(db(1 : loc(1) - 1));
        product = EnumType.Product.ToEnum(db(loc(1) + 1 : end));

    case 3
        inv = EnumType.Interval.ToEnum(db(1 : loc(1) - 1));
        product = EnumType.Product.ToEnum(db(loc(1) + 1 : loc(2) - 1));

    otherwise
        error('Can''t recognise databasse ''%s'', please check !', db);
end

% backup by product
switch product
    case {EnumType.Product.ETF, EnumType.Product.Index}
        BackupEtfIndex(obj, product, inv, db, tbs, dir_sav);

    case {EnumType.Product.Future}
        BackupFuture(obj, inv, db, tbs, dir_sav);

    case {EnumType.Product.Option}
        BackupOption(obj, inv, db, tbs, dir_sav);

    otherwise
        error('Unexpected condition, please check !');
end
end

% backup etf & index
function BackupEtfIndex(obj, product, inv, db, tbs, dir_sav)
for i = 1 : length(tbs)
    this = tbs{i};
    loc = strfind(this, '_');
    variety = this(1 : loc - 1);
    exchange = EnumType.Exchange.ToEnum(this(loc + 1 : end));
    asset = BaseClass.Asset.Asset.Selector(product, variety, exchange, inv);
    fprintf(2, 'Backuping [%s]-[%s], [%i/%i], please wait ...\r', db, this, i, length(tbs));
    md = obj.db.LoadMarketData(asset);
    asset.MergeMarketData(md);
    obj.dr.SaveMarketData(asset, dir_sav);
end
end

% backup future
function BackupFuture(obj, inv, db, tbs, dir_sav)
% determin variety & exchange
loc = strfind(db, '-');
variety = db(loc(2) + 1 : loc(3) - 1);
exchange = EnumType.Exchange.ToEnum(db(loc(3) + 1 : end));

% gen sample
asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Future, variety, exchange, 'SYMBOL', 'SECNAME', inv, 100, datestr(now()),  datestr(now()), 0.12, 1, 0.05);

% sav
for i = 1 : length(tbs)
    asset.symbol = tbs{i};
    asset.md = [];
    fprintf(2, 'Backuping [%s]-[%s], [%i/%i], please wait ...\r', db, asset.symbol , i, length(tbs));
    md = obj.db.LoadMarketData(asset);
    asset.MergeMarketData(md);
    obj.dr.SaveMarketData(asset, dir_sav);
end
end

% backup option
function BackupOption(obj, inv, db, tbs, dir_sav)
% determin variety & exchange
loc = strfind(db, '-');
variety = db(loc(2) + 1 : loc(3) - 1);
exchange = EnumType.Exchange.ToEnum(db(loc(3) + 1 : end));

% gen sample
switch upper(variety)
    case {'159919', '510050', '510300', 'IO'}
        asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Option, variety, exchange, 'Symbol', 'SECNAME', inv, 100, EnumType.CallOrPut.Call, 1000, datestr(now()),  datestr(now()));

    otherwise
        asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Option, variety, exchange, 'Symbol', 'SECNAME', inv, 100, EnumType.CallOrPut.Call, 1000, datestr(now()),  datestr(now()), ...
            'Future Symbol', 'Future SECNAME', 100, datestr(now()),  datestr(now()), 0.12, 1, 0.05);
end

% sav
for i = 1 : length(tbs)
    asset.symbol = tbs{i};
    asset.md = [];
    fprintf(2, 'Backuping [%s]-[%s], [%i/%i], please wait ...\r', db, asset.symbol, i, length(tbs));
    md = obj.db.LoadMarketData(asset);
    asset.MergeMarketData(md);
    obj.dr.SaveMarketData(asset, dir_sav);
end
end

%% DataManager / DatabaseBackupOld
% % v1.3.0.20220113.beta
% %      1.首次加入
% function DatabaseBackupOldVer(obj, dir_rt)
% % 预处理
% db_ig_lst = {'1D-ETF', '1D-FUTURE-CU-SHFE', '1D-FUTURE-IF-CFFEX', '1D-FUTURE-M-DCE', '1D-FUTURE-SC-INE', '1D-FUTURE-SR-CZCE', '1D-INDEX', '1D-OPTION-510050-SSE', '1MIN-ETF', ...
%     '5MIN-OPTION-510050-SSE', '5MIN-OPTION-510300-SSE', 'Calendar', 'Interest', 'master', 'model', 'msdb',  'tempdb', 'INSTRUMENTS', 'ReportServer$BRIDGE', 'ReportServer$BRIDGETempDB', ...
%     'Tushare_calendar', 'Tushare_fund', 'Tushare_index', 'Tushare_interest', '1D-OPTION-510300-SSE', 'ReportServer$BRIDGE_DB', 'ReportServer$BRIDGE_DBTempDB', 'Future_ME_CZC', ...
%     'Future_TC_CZC', 'Future_WT_CZC', 'Future_WS_CZC', 'Future_IM_SHF'};
% tb_ig_lst = {'CodeList', '000188.SH', 'sysdiagrams'};
%
% % 读取所有数据库
% dbs = obj.db.FetchAllDbs();
% dbs = setdiff(dbs, db_ig_lst);
%
% % 逐一读取数据
% for i = 1 : length(dbs)
%     tbs = obj.db.FetchAllTables(dbs{i});
%     tbs = setdiff(tbs, tb_ig_lst);
%
%     for j = 1 : length(tbs)
%         % 读取数据
%         curr_db = dbs{i};
%         curr_tb = tbs{j};
%
%         % 生成资产 / 品种 / 交易所
%         loc = strfind(curr_db, '_');
%         if (isempty(loc))
%             if (strcmp(curr_db, 'Fund'))
%                 pdt = EnumType.Product.ETF;
%                 loc = strfind(curr_tb, '.');
%                 var = curr_tb(1 : loc(1) - 1);
%                 switch var
%                     case '510050'
%                         exc = EnumType.Exchange.SSE;
%                     case '510300'
%                         exc = EnumType.Exchange.SSE;
%                     case '159919'
%                         exc = EnumType.Exchange.SZSE;
%                 end
%             else
%                 pdt = EnumType.Product.ToEnum(curr_db);
%                 loc = strfind(curr_tb, '.');
%                 var = curr_tb(1 : loc(1) - 1);
%                 exc = EnumType.Exchange.ToEnum(curr_tb(loc(1) + 1 : end));
%             end
%         else
%             pdt = EnumType.Product.ToEnum(curr_db(1 : loc(1) - 1));
%             var = curr_db(loc(1) + 1 : loc(2) - 1);
%             exc = EnumType.Exchange.ToEnum(curr_db(loc(2) + 1 : end));
%         end
%         inv = EnumType.Interval.day;
%
%         % 生成合约
%         switch pdt
%             case {EnumType.Product.ETF, EnumType.Product.Index}
%                 asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, inv);
%             case EnumType.Product.Option
%                 switch var
%                     case {'510050', '510300', '159919', 'IO'}
%                         symbol = curr_tb(1 : strfind(curr_tb, '.') - 1);
%                         asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, symbol, 'sec_name', inv, 10000, EnumType.CallOrPut.Call, 999, datestr(now()), datestr(now()));
%                     otherwise
%                         symbol = curr_tb(1 : strfind(curr_tb, '.') - 1);
%                         asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, symbol, 'sec_name', inv, 10000, EnumType.CallOrPut.Call, 999, datestr(now()), datestr(now()), ...
%                             'future symbol', 'future sec name', 10000, datestr(now()), datestr(now()), 0.12, 1, 0.5);
%                 end
%
%             case EnumType.Product.Future
%                 symbol = curr_tb(1 : strfind(curr_tb, '.') - 1);
%                 asset = BaseClass.Asset.Asset.Selector(pdt, var, exc, symbol, 'sec_name', inv, 10000, datestr(now()), datestr(now()), 0.12, 1, 0.5);
%         end
%
%
%         % 读取数据 / 整理数据
%         md = obj.db.FetchRawData(curr_db, curr_tb);
%         md(:, 1) = [];
%         switch pdt
%             case EnumType.Product.ETF
%                 loc = logical(sum(isnan(md), 2));
%                 md(loc, :) = [];
%                 md(:, 8 : 9) = md(:, [9, 8]);
%
%             case EnumType.Product.Index
%                 loc = logical(sum(isnan(md), 2));
%                 md(loc, :) = [];
%                 md(:, 6 : 7) = md(:, [7, 6]);
%
%             case EnumType.Product.Option
%                 md = md(:, [1 : 10, 20 : 21]);
%                 md(:, 6 : 7) = md(:, [7, 6]);
%
%             case EnumType.Product.Future
%                 md(:, [8, 13]) = [];
%                 md(:, 6 : 7) = md(:, [7, 6]);
%                 md(isnan(md)) = 0;
%             otherwise
%                 error('unexpected condition');
%         end
%
%         % 保存
%         fprintf('Saving [%s]@[%s], table [%i/%i], database [%i/%i], please wait ...\r', curr_tb, curr_db, j, length(tbs), i, length(dbs));
%         asset.MergeMarketData(md);
%         obj.dr.SaveMarketData(asset, dir_rt);
%     end
%
% end
%
% end