% DataManager / DatabaseBackup
% v1.3.0.20220113.beta
%      1.首次加入
function DatabaseRestore(obj, dir_bak)

% 预处理
folder_ins = 'INSTRUMENTS';
folder_cal = 'CALENDAR';
folders = LocateAvailablePath(dir_bak, folder_ins, folder_cal);

% 逐一入库
for i = 1 : length(folders)
    fprintf(2, 'Restoring progress [%i/%i], please wait ...\r', i ,length(folders));
    this = folders(i);
    switch this.name
        case folder_cal
            % 入库日历
            RestoreCalendar(obj, dir_bak);
            
        case folder_ins
            % 入库合约表
            RestoreInstruments(obj, dir_bak, folder_ins);            
            
        otherwise
            % 入库资产
            RestoreAsset(obj, dir_bak, this.name);
    end
end
end

% 定位可用路径
function folders = LocateAvailablePath(dir_bak, folder_ins, folder_cal)
folders = dir(dir_bak);
for i = length(folders) : -1 : 1
    this = folders(i);
    if (strcmp(this.name, '.'))
        folders(i) = [];
    elseif (strcmp(this.name, '..'))
        folders(i) = [];
    elseif (~this.isdir)
        folders(i) = [];
    elseif (strcmp(this.name, folder_ins) || (strcmp(this.name, folder_cal)))
        continue;
    else
        loc = strfind(this.name, '-');
        if (isempty(loc))
            folders(i) = [];
        else
            inv = this.name(1 : loc(1) - 1);
            try
                EnumType.Interval.ToEnum(inv);
            catch
                folders(i) = [];
            end
            continue;
        end
    end
end
end


% 入库日历
function RestoreCalendar(obj, dir_bak)
fprintf('Restoring [Calendar], please wait ...\r');
cal = obj.dr.LoadCalendar(dir_bak);
obj.db.SaveCalendar(cal);
end


% 入库合约表
function RestoreInstruments(obj, dir_bak, folder_ins)
% 读取所有合约表
files = dir(fullfile(dir_bak, folder_ins));
files([files.isdir]) = [];

% 逐一读取入库
for i = 1 : length(files)
    this = files(i);
    loc_hyphen = strfind(this.name, '-');
    loc_dot = strfind(this.name, '.');
    try
        product = EnumType.Product.ToEnum(this.name(1 : loc_hyphen(1) - 1));
        variety = this.name(loc_hyphen(1) + 1 : loc_hyphen(2) - 1);
        exchange = EnumType.Exchange.ToEnum(this.name(loc_hyphen(2) + 1 : loc_dot(1) - 1));
        fprintf('Restoring [Instruments]-[%s], please wait ...\r', this.name(1 : loc_dot(1) - 1));
    catch
        fprintf(2, 'Restoring Error, can''t find information in [%s], please check !\r', fullfile(this.folder, this.name));
        continue;
    end
    
    ins = obj.dr.LoadChain(product, variety, exchange, dir_bak);
    obj.db.SaveChain(product, variety, exchange, ins);
end
end

% 入库资产
function RestoreAsset(obj, dir_bak, folder)
% 确定周期 / 品种
loc = strfind(folder, '-');
switch length(loc)
    case 1
        inv = EnumType.Interval.ToEnum(folder(1 : loc(1) - 1));
        product = EnumType.Product.ToEnum(folder(loc(1) + 1 : end));
        
    case 3
        inv = EnumType.Interval.ToEnum(folder(1 : loc(1) - 1));
        product = EnumType.Product.ToEnum(folder(loc(1) + 1 : loc(2) - 1));
        
    otherwise
        error('Can''t recognise folder ''%s\\'', please check !', fullfile(dir_bak, folder));
end

% 读取文件
path = fullfile(dir_bak, folder);
files = dir(path);
files([files.isdir]) = [];

% 逐一入库
switch product
    case {EnumType.Product.ETF, EnumType.Product.Index}
        RestoreEtfIndex(obj, product, inv, dir_bak, folder, files);
        
    case {EnumType.Product.Future}
        RestoreFuture(obj, inv, dir_bak, folder, files);
        
    case {EnumType.Product.Option}
        RestoreOption(obj, inv, dir_bak, folder, files);
        
    otherwise
        error('Unexpected condition, please check !');
end
end

% 还原 ETF / Index
function RestoreEtfIndex(obj, product, inv, dir_bak, folder, files)
for i = 1 : length(files)
    this = files(i);
    loc1 = strfind(this.name, '_');
    loc2 = strfind(this.name, '.');
    variety = this.name(1 : loc1 - 1);
    exchange = EnumType.Exchange.ToEnum(this.name(loc1 + 1 : loc2 - 1));
    asset = BaseClass.Asset.Asset.Selector(product, variety, exchange, inv);
    fprintf(2, 'Restoring [%s]-[%s-%s], [%i/%i], please wait ...\r', folder, asset.symbol, Utility.ToString(asset.exchange), i, length(files));
    obj.dr.LoadMarketData(asset, dir_bak);
    obj.db.SaveMarketData(asset);
end
end

% 还原 Future
function RestoreFuture(obj, inv, dir_bak, folder, files)
% 确定品种
loc = strfind(folder, '-');
variety = folder(loc(2) + 1 : loc(3) - 1);
exchange = EnumType.Exchange.ToEnum(folder(loc(3) + 1 : end));

% 生成样本
asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Future, variety, exchange, 'Symbol', 'SECNAME', inv, 100, datestr(now()),  datestr(now()), 0.12, 1, 0.05);

% 还原
for i = 1 : length(files)
    this = files(i);
    loc = strfind(this.name, '.');
    symb = this.name(1 : loc(1) - 1);
    asset.symbol = symb;
    asset.md = [];
    fprintf(2, 'Restoring [%s]-[%s], [%i/%i], please wait ...\r', folder, symb, i, length(files));
    obj.dr.LoadMarketData(asset, dir_bak);
    obj.db.SaveMarketData(asset);
end
end

% 还原 Option
function RestoreOption(obj, inv, dir_bak, folder, files)
% 确定品种
loc = strfind(folder, '-');
variety = folder(loc(2) + 1 : loc(3) - 1);
exchange = EnumType.Exchange.ToEnum(folder(loc(3) + 1 : end));


% 生成样本
switch upper(variety)
    case {'159919', '510050', '510300', 'IO'}
        asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Option, variety, exchange, 'Symbol', 'SECNAME', inv, 100, EnumType.CallOrPut.Call, 1000, datestr(now()),  datestr(now()));
        
    otherwise
        asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Option, variety, exchange, 'Symbol', 'SECNAME', inv, 100, EnumType.CallOrPut.Call, 1000, datestr(now()),  datestr(now()), ...
            'Future Symbol', 'Future SECNAME', 100, datestr(now()),  datestr(now()), 0.12, 1, 0.05);
end

% 还原
for i = 1 : length(files)
    this = files(i);
    asset.symbol = this.name(1 : strfind(this.name, '.') - 1);
    asset.md = [];
    fprintf(2, 'Restoring [%s]-[%s], [%i/%i], please wait ...\r', folder, asset.symbol, i, length(files));
    obj.dr.LoadMarketData(asset, dir_bak);
    obj.db.SaveMarketData(asset);
end
end

