% DataManager / Update
% v1.3.0.20220113.beta
%      1.First Commit
function Update(obj)

Calendar(obj);
Index(obj);
ETF(obj);
Option(obj, EnumType.Interval.day);
Option(obj, EnumType.Interval.min5);

end

% Calendar
function Calendar(obj)
obj.LoadCalendar();
end

% Index
function Index(obj)
% 预处理
inv = EnumType.Interval.day;
upd_lst = struct;
upd_lst.product = EnumType.Product.Index;                     upd_lst.variety = '000001';             upd_lst.exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000016';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000300';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '000905';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399001';     upd_lst(end).exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399005';     upd_lst(end).exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.Index;       upd_lst(end).variety = '399006';     upd_lst(end).exchange = EnumType.Exchange.SZSE;

% 载入行情摘要
this = upd_lst(1);
sample = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, inv);
views = obj.db.LoadOverviews(sample);

% 更新
for i = 1 : length(upd_lst)
    % 生成资产
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));
    asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, inv);

    % check database md
    view = views(ismember(views.TABLENAME, BaseClass.Database.Database.GetTableName(asset)), :);
    if (~isempty(view) && view.COUNTS)
        [mark, ~, ~] = obj.NeedUpdate(asset, datenum(view.TS_START), datenum(view.TS_END));
        if (~mark)
            continue;
        end
    end

    % check local csv md
    [md_local, mark, dt_s, dt_e] = obj.LoadMdViaCsv(asset);
    if (~mark)
        obj.db.SaveMarketData(asset, md_local);
        continue;
    end

    % fetch datasource
    asset.MergeMarketData(md_local);
    md = LoadViaDs(obj, asset, dt_s, dt_e);
    if (~isempty(md))
        asset.MergeMarketData(md);
        obj.db.SaveMarketData(asset, md);
        obj.dr.SaveMarketData(asset, obj.dir_root);
    end
end
end

% ETF
function ETF(obj)
% 预处理
inv = EnumType.Interval.day;
upd_lst = struct;
upd_lst.product = EnumType.Product.ETF;                      upd_lst.variety = '159919';            upd_lst.exchange = EnumType.Exchange.SZSE;
upd_lst(end + 1).product = EnumType.Product.ETF;       upd_lst(end).variety = '510050';     upd_lst(end).exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.ETF;       upd_lst(end).variety = '510300';     upd_lst(end).exchange = EnumType.Exchange.SSE;

% 载入行情摘要
this = upd_lst(1);
sample = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, inv);
views = obj.db.LoadOverviews(sample);

for i = 1 : length(upd_lst)
    % 生成资产
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));
    asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, inv);

    % check database md
    view = views(ismember(views.TABLENAME, BaseClass.Database.Database.GetTableName(asset)), :);
    if (~isempty(view) && view.COUNTS)
        [mark, ~, ~] = obj.NeedUpdate(asset, datenum(view.TS_START), datenum(view.TS_END));
        if (~mark)
            continue;
        end
    end

    % check local csv md
    [md_local, mark, dt_s, dt_e] = obj.LoadMdViaCsv(asset);
    if (~mark)
        obj.db.SaveMarketData(asset, md_local);
        continue;
    end

    % fetch datasource
    asset.MergeMarketData(md_local);
    md = LoadViaDs(obj, asset, dt_s, dt_e);
    if (~isempty(md))
        asset.MergeMarketData(md);
        obj.db.SaveMarketData(asset, md);
        obj.dr.SaveMarketData(asset, obj.dir_root);
    end
end
end

% Option
function Option(obj, inv)
% 预处理
upd_lst = struct;
upd_lst.product = EnumType.Product.Option;                     upd_lst.variety = '510050';             upd_lst.exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Option;       upd_lst(end).variety = '510300';     upd_lst(end).exchange = EnumType.Exchange.SSE;

for i = 1 : length(upd_lst)
    % 读取所有合约
    this = upd_lst(i);
    fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));
    ins = obj.LoadChain(this.product, this.variety, this.exchange);

    % 载入行情摘要
    this = upd_lst(i);
    info = ins(1, :);
    sample = SampleOption(info, this.product, this.variety, this.exchange, inv);
    views = obj.db.LoadOverviews(sample);

    % 更新
    for j = 1 : height(ins)
        % 提取摘要
        info = ins(j, :);
        fprintf('Updating [%s-%s-%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(inv), Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), info.SYMBOL{:}, j, height(ins));

        % check database md
        view = views(ismember(views.TABLENAME, info.SYMBOL{:}), :);
        if (~isempty(view) && view.COUNTS)
            if ((inv == EnumType.Interval.day && datenum(view.TS_END) < datenum(info.END_TRADE_DATE{:}, 'yyyy-mm-dd')) || (inv == EnumType.Interval.min5 && datenum(view.TS_END) < datenum(info.END_TRADE_DATE{:}, 'yyyy-mm-dd HH:MM')))
                asset = SampleOption(info, this.product, this.variety, this.exchange, inv);
                [mark, ~, ~] = obj.NeedUpdate(asset, datenum(view.TS_START), datenum(view.TS_END));
                if (~mark)
                    continue;
                end
            else
                continue;
            end
        else
            asset = SampleOption(info, this.product, this.variety, this.exchange, inv);
        end

        % check local csv md
        [md_local, mark, dt_s, dt_e] = obj.LoadMdViaCsv(asset);
        if (~mark)
            obj.db.SaveMarketData(asset, md_local);
            continue;
        end

        % fetch datasource
        asset.MergeMarketData(md_local);
        md = LoadViaDs(obj, asset, dt_s, dt_e);
        if (~isempty(md))
            asset.MergeMarketData(md);
            obj.db.SaveMarketData(asset, md);
            obj.dr.SaveMarketData(asset, obj.dir_root);
        end
    end
end

end

% 获取期权样本
function asset_ = SampleOption(info_, pdt_, var_, exc_, inv_)
switch var_
    case {'159919', '510050', '510300'}
        asset_ = BaseClass.Asset.Asset.Selector(pdt_, var_, exc_, ...
            info_.SYMBOL{:}, ...
            info_.SEC_NAME{:}, ...
            inv_, ...
            info_.SIZE, ...
            EnumType.CallOrPut.ToEnum(info_.CALL_OR_PUT{:}), ...
            info_.STRIKE, ...
            info_.START_TRADE_DATE{:}, ...
            info_.END_TRADE_DATE{:}...
            );

    otherwise
        error('Unsupported variety for updating, please check !');
end
end

%% DEBUG
% % Debug Function：Check Option Min Md Data
% function InsertOptionMin(obj)
% upd_lst = struct;
% upd_lst.product = EnumType.Product.Option;                     upd_lst.variety = '510050';            upd_lst.exchange = EnumType.Exchange.SSE;
% upd_lst(end + 1).product = EnumType.Product.Option;       upd_lst(end).variety = '510300';     upd_lst(end).exchange = EnumType.Exchange.SSE;
% for i = 1 : length(upd_lst)
%     % 读取所有合约
%     this = upd_lst(i);
%     fprintf('Updating [%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), i, length(upd_lst));
%     ins = obj.LoadChain(this.product, this.variety, this.exchange);
% 
%     % 更新
%     for j = 1 : height(ins)
%         info = ins(j, :);
%         switch this.variety
%             case {'159919', '510050', '510300'}
%                 asset = BaseClass.Asset.Asset.Selector(this.product, this.variety, this.exchange, ...
%                     info.SYMBOL{:}, ...
%                     info.SEC_NAME{:}, ...
%                     EnumType.Interval.day, ...
%                     info.SIZE, ...
%                     EnumType.CallOrPut.ToEnum(info.CALL_OR_PUT{:}), ...
%                     info.STRIKE, ...
%                     info.START_TRADE_DATE{:}, ...
%                     info.END_TRADE_DATE{:}...
%                     );
% 
%             otherwise
%                 error('Unsupported variety for updating, please check !');
%         end
%         fprintf('Updating [%s-%s-%s-%s], [%i/%i], please wait ...\r', Utility.ToString(this.product), this.variety, Utility.ToString(this.exchange), asset.symbol, j, height(ins));
% 
%         asset.interval = EnumType.Interval.day;
%         LoadMd(obj, asset);
%         asset.md = [];
% 
%         asset.interval = EnumType.Interval.min5;
%         LoadMd(obj, asset);
%     end
% end
% end
% 
% % Debug Function: Load Data without datasource
% function LoadMd(obj, asset)
% % 读取数据库
% md_local = obj.db.LoadMarketData(asset);
% [mark, ~, ~] = NeedUpdate(obj, asset, md_local);
% if (~mark)
%     return;
% end
% 
% % 读取本地 csv
% md_local = obj.dr.LoadMarketData(asset, obj.dir_root);
% [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md_local);
% if (~mark)
%     asset.MergeMarketData(md_local);
%     obj.db.SaveMarketData(asset, md_local);
%     return;
% end
% 
% if (isempty(md_local))
%     return;
% end
% 
% if (now() < datenum(asset.GetDateExpire()))
%     return;
% end
% 
% persistent counter;
% if (~isempty(counter))
%     counter = counter + 1;
% else
%     counter = 0;
% end
% 
% datefmt = 'yyyy-mm-dd HH:MM';
% id = fopen('C:\Users\dell\Desktop\err_record.txt', 'a+');
% fprintf(id, '[Counter:%d]-[Interval:%s]-[Symbol:%s]\t\rListed:%s\tExpire:%s\rMdStart:%s\tMdEnd:%s\rUpdStart:%s\tUpdEnd:%s\r\r', ...
%     counter, ...
%     Utility.ToString(asset.interval), asset.symbol, ...
%     datestr(asset.GetDateListed(), datefmt), ...
%     datestr(asset.GetDateExpire(), datefmt), ...
%     datestr(md_local(1, 1), datefmt), ...
%     datestr(md_local(end, 1), datefmt), ...
%     datestr(dt_s, datefmt), ...
%     datestr(dt_e, datefmt));
% fclose(id);
% end
% 
% % Debug Function: Judge whether need update
% function [mark, dt_s, dt_e] = NeedUpdate(obj, asset, md)
% % 读取交易日历 / 获取最后交易日
% persistent cal;
% if (isempty(cal))
%     cal = obj.LoadCalendar();
% end
% if hour(now()) >= 15
%     td = now();
% else
%     td = now() - 1;
% end
% last_trade_date = find(cal(:, 5) <= td, 1, 'last');
% last_trade_date = cal(find(cal(1 : last_trade_date, 2) == 1, 1, 'last'), 5);
% 
% 
% if (~isempty(md))
%     % 有行情
%     % 确定理论起点终点
%     if (asset.product == EnumType.Product.ETF)
%         dt_s_o = datenum(asset.GetDateInit()) + 40;
%         dt_e_o = last_trade_date + 15 / 24;
%     elseif (asset.product == EnumType.Product.Index)
%         dt_s_o = datenum(asset.GetDateInit());
%         dt_e_o = last_trade_date + 15 / 24;
%     elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
%         dt_s_o =  datenum(asset.GetDateListed());
%         dt_e_o = datenum(asset.GetDateExpire());
%         if (dt_e_o > last_trade_date)
%             dt_e_o = last_trade_date + 15 / 24;
%         end
%     else
%         error('Unexpected "product" for update start point determine, please check.');
%     end
% 
%     % 定位已有起点终点
%     md_s = md(1, 1);
%     md_e = md(end, 1);
% 
%     %  判定起点
%     if (md_s - dt_s_o >= 1)
%         dt_s = dt_s_o;
%     else
%         dt_s = md_e;
%     end
% 
%     % 判定终点
%     if (asset.interval == EnumType.Interval.min1 || asset.interval == EnumType.Interval.min5)
%         if (dt_e_o - md_e < 15 / 60 / 24)
%             dt_e = md_e;
%         else
%             dt_e = dt_e_o;
%         end
% 
%     elseif (asset.interval == EnumType.Interval.day)
%         dt_e_o = floor(dt_e_o);
%         if (dt_e_o - md_e < 1)
%             dt_e = md_e;
%         else
%             dt_e = dt_e_o;
%         end
%     else
%         error("Unexpected 'interval' for market data accomplished judgement, please check.");
%     end
% 
%     % 判定是否更新
%     if (dt_s == dt_e && dt_e == md_e)
%         mark = false;
%     else
%         mark = true;
%     end
% 
% else
%     % 无行情
%     % 确定更新起点
%     if (asset.product == EnumType.Product.ETF || asset.product == EnumType.Product.Index)
%         dt_s = datenum(asset.GetDateInit());
%     elseif (asset.product == EnumType.Product.Future || asset.product == EnumType.Product.Option)
%         dt_s =  datenum(asset.GetDateListed());
%     else
%         error('Unexpected "product" for update start point determine, please check.');
%     end
% 
%     % 确定更新终点
%     dt_e = last_trade_date + 15 / 24;
%     mark = true;
% end
% end
% 
% 
%% Fix Local Quetos
% function FixLocalQuote(obj)
% %% preprocess
% dir_udt = 'D:\OneDrive\hisdata\update';
% dir_out = 'D:\OneDrive\hisdata\update\fixed';
% 
% % symb_mis_front
% % 41~48             8
% % 65~72             8
% % 615~626       12
% % 629~640       12
% % 945~946       12
% % 949~952        4
% % 1021~1022    2
% % 1151~1170    20
% tmp = (10000041 : 10000048)';
% tmp = [tmp; (10000065 : 10000072)'];
% tmp = [tmp; (10000615 : 10000626)'];
% tmp = [tmp; (10000629 : 10000640)'];
% tmp = [tmp; (10000945 : 10000946)'];
% tmp = [tmp; (10000949 : 10000952)'];
% tmp = [tmp; (10001021 : 10001022)'];
% tmp = [tmp; (10001151 : 10001170)'];
% symb_mis_front = arrayfun(@(x) {num2str(x)}, tmp);
% 
% % symb_mis_rear
% % 933~944       12
% % 955, 956, 963, 964, 979, 980      6
% tmp = (10000933 : 10000944)';
% tmp = [tmp; [10000955, 10000956, 10000963, 10000964, 10000979, 10000980]'];
% symb_mis_rear = arrayfun(@(x) {num2str(x)}, tmp);
% 
% % symb_mis_both
% % 947, 948,         2
% tmp = (10000947 : 10000948)';
% symb_mis_both = arrayfun(@(x) {num2str(x)}, tmp);
% 
% % load instrus & calendar & symbol pool
% ins = obj.LoadChain(EnumType.Product.Option, '510050', EnumType.Exchange.SSE);
% cal = LoadCalendar(obj);
% symbols = union(union(symb_mis_front, symb_mis_rear), symb_mis_both);
% 
% 
% %% fix operation
% for i = 1 : length(symbols)
%     % fetch local queto
%     symb = symbols(i);
%     info = ins(ismember(ins.SYMBOL, symb), :);
%     asset = BaseClass.Asset.Asset.Selector(EnumType.Product.Option, '510050', EnumType.Exchange.SSE, ...
%         info.SYMBOL{:}, ...
%         info.SEC_NAME{:}, ...
%         EnumType.Interval.min5, ...
%         info.SIZE, ...
%         EnumType.CallOrPut.ToEnum(info.CALL_OR_PUT{:}), ...
%         info.STRIKE, ...
%         info.START_TRADE_DATE{:}, ...
%         info.END_TRADE_DATE{:}...
%         );
%     LoadMd(obj, asset);
% 
%     % fetch update queto
%     md_upd = LoadUpdateMd(dir_udt, symb{:});
% 
%     if (ismember(symb, symb_mis_front))
%         % missing front
%         dt_fix_s = str2double(datestr(asset.GetDateListed(), 'yyyymmdd'));
%         dt_fix_e = asset.md(1, 2);
%         dt_missing = cal(cal(:, 1) >= dt_fix_s & cal(:, 1) < dt_fix_e & cal(:, 2), 5);
%         fprintf(2, '%s missing [front], %i day(s), total progress %i/%i,, please wait ...\r', symb{:}, length(dt_missing), i, length(symbols));
%         disp(datestr(dt_missing));
%         fprintf('\r');
% 
%     elseif (ismember(symb, symb_mis_rear))
%         % missing rear
%         dt_fix_s = asset.md(end, 2);
%         dt_fix_e = str2double(datestr(asset.GetDateExpire(), 'yyyymmdd'));
%         dt_missing = cal(cal(:, 1) > dt_fix_s & cal(:, 1) <= dt_fix_e & cal(:, 2), 5);
%         fprintf(2, '%s missing [rear], %i day(s), total progress %i/%i,, please wait ...\r', symb{:}, length(dt_missing), i, length(symbols));
%         disp(datestr(dt_missing));
%         fprintf('\r');
% 
%     elseif (ismember(symb, symb_mis_both))
%         % missing both
%         dt_fix_s = str2double(datestr(asset.GetDateListed(), 'yyyymmdd'));
%         dt_fix_e = asset.md(1, 2);
%         mis_1 = cal(cal(:, 1) >= dt_fix_s & cal(:, 1) < dt_fix_e & cal(:, 2), 5);
% 
%         dt_fix_s = asset.md(end, 2);
%         dt_fix_e = str2double(datestr(asset.GetDateExpire(), 'yyyymmdd'));
%         mis_2 = cal(cal(:, 1) > dt_fix_s & cal(:, 1) <= dt_fix_e & cal(:, 2), 5);
%         dt_missing = union(mis_1, mis_2)';
%         fprintf(2, '%s missing [both], %i day(s), total progress %i/%i,, please wait ...\r', symb{:}, length(dt_missing), i, length(symbols));
%         disp(datestr(dt_missing));
%         fprintf('\r');
% 
%     end
% 
%     % fix
%     for j = 1 : size(dt_missing, 1)
%         md_fix = FixMarketData(dt_missing(j), md_upd);
%         asset.MergeMarketData(md_fix);
%     end
% 
%     % save data
%     SaveBar(asset, dir_out);
% 
% end
% end
% 
% % debug function ： gen sse time axis
% function axis = GenSseTimeAxis(dt_dm)
% am = [930, 935, 940, 945, 950, 955, 1000, 1005, 1010, 1015, 1020, 1025, 1030, 1035, 1040, 1045, 1050, 1055, 1100, 1105, 1110 , 1115 , 1120 , 1125, 1130];
% pm = [1305, 1310, 1315, 1320, 1325, 1330, 1335, 1340, 1345, 1350, 1355, 1400, 1405, 1410, 1415, 1420, 1425, 1430, 1435, 1440, 1445, 1450, 1455, 1500];
% axis = [am, pm]';
% 
% date = datevec(dt_dm);
% date = repmat(date, length(axis), 1);
% hour = floor(axis / 100);
% date(:, 4) = hour;
% date(:, 5) = axis - hour * 100;
% 
% axis = datenum(date);
% end
% 
% % debug function ： load update maketdata
% function md = LoadUpdateMd(dir_upd, symb)
% md = readtable(fullfile(dir_upd, [symb, '.xlsx']), 'PreserveVariableNames', 1);
% if (~isequal(md{1, 1}{:}(1 : 8), symb))
%     error('symbol error %s', symb);
% end
% md = table2cell(md);
% md(:, 1 : 2) = [];
% md(:, 1) = cellfun(@(x) {datenum(x)}, md(:, 1));
% md = cell2mat(md);
% md(isnan(md(:, 1)), :) = [];
% md(:, 6) = md(:, 6) * 1000000;
% md(:, 8) = 0;
% end

% % debug function:  fix market data
% function md_fix = FixMarketData(date_mis, md_upd)
% axis = GenSseTimeAxis(date_mis);
% md_fix = [];
% for k = 2 : size(axis, 1)
%     s = axis(k - 1);
%     e = axis(k);
%     if (k ~= 2)
%         tmp_md = md_upd(md_upd(:, 1) > s & md_upd(:, 1) <= e, :);
%     else
%         tmp_md = md_upd(md_upd(:, 1) >= s & md_upd(:, 1) <= e, :);
%     end
%     dt = e;
%     if (~isempty(tmp_md))
%         open = tmp_md(1, 2);
%         high = max(max(tmp_md(:, 2 : 5)));
%         low = min(min(tmp_md(:, 2 : 5)));
%         close = tmp_md(end, 5);
%         turnover = sum(tmp_md(:, 6));
%         volume = sum(tmp_md(:, 7));
%         oi = 0;
%         md_fix = [md_fix; [dt, open, high, low, close, turnover, volume, oi]];
%     else
%         md_fix = [md_fix; [dt, zeros(1, 7)]];
%     end
% end
% end
% 
% % debug func: save bar
% function SaveBar(asset, dir_)
% 预处理
% 生成输出目录
% dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
% Utility.CheckDirectory(dir_);
% 
% % 生成输出文件名
% filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) +  ".csv");
% 
% % 整列表头 / 数据格式
% header = 'datetime,open,high,low,last,turnover,volume,oi\r';
% dat_fmt = '%s,%.4f,%.4f,%.4f,%.4f,%i,%i,%i\r';
% 
% % 写入表头 / 写入数据
% id = fopen(filename, 'w');
% fprintf(id, header);
% for i = 1 : size(asset.md, 1)
%     this = asset.md(i, :);
%     fprintf(id, dat_fmt, datestr(this(1), 'yyyy-mm-dd HH:MM'), this(4 : end));
% end
% fclose(id);
% end


%% check data
function Check(obj, inv)
upd_lst = struct;
upd_lst.product = EnumType.Product.Option;                     upd_lst.variety = '510050';             upd_lst.exchange = EnumType.Exchange.SSE;
upd_lst(end + 1).product = EnumType.Product.Option;       upd_lst(end).variety = '510300';     upd_lst(end).exchange = EnumType.Exchange.SSE;

for i = 1 : length(upd_lst)
    % 读取所有合约
    this = upd_lst(i);
    ins = obj.LoadChain(this.product, this.variety, this.exchange);

    % 载入行情摘要
    this = upd_lst(i);
    info = ins(1, :);
    sample = SampleOption(info, this.product, this.variety, this.exchange, inv);
    views = obj.db.LoadOverviews(sample);

    % 更新
    for j = 1 : height(ins)
        % 提取摘要
        info = ins(j, :);
        view = views(ismember(views.TABLENAME, info.SYMBOL{:}), :);

        s_ins = datenum(info.START_TRADE_DATE, 'yyyy-mm-dd');
        e_ins = datenum(info.END_TRADE_DATE, 'yyyy-mm-dd');
        s_view = datenum(view.TS_START, 'yyyy-mm-dd');
        e_view = datenum(view.TS_END, 'yyyy-mm-dd');
        if (s_view < s_ins || e_ins < e_view)
            disp(info.SYMBOL);
        end
    end
end
end