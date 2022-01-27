% DataManager / DatabaseBackup
% v1.3.0.20220113.beta
%      1.首次加入
function DatabaseBackup(obj, dir_sav)
% 获取�?要备份的数据�?
db_ins = 'INSTRUMENTS';
db_calendar = 'CALENDAR';
dbs = FetchAllDatabase(obj, db_ins, db_calendar);

% 逐一读取数据
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


% 获取�?要备份的数据�?
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
    obj.db.LoadMarketData(asset);
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