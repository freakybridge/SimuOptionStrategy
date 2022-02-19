% iFinD 获取期权合约列表
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, ins] = FetchChainOption(obj, opt_s, ins_local)

% 获取下载起点终点
[date_s, date_e] = obj.GetChainUpdateSE(opt_s, ins_local);

% 获取参数
if (isa(opt_s, 'BaseClass.Asset.Option.Instance.SSE_510050'))
    param = '171002001';
elseif (isa(opt_s, 'BaseClass.Asset.Option.Instance.SSE_510300'))
    param = '171002002';
elseif (isa(opt_s, 'BaseClass.Asset.Option.Instance.SZSE_159919'))
    param = '171003006';
else
    error("Unexpected option class type, please check!");
end

% 下载合约代码
symbols = [];
for i = datenum(date_s) : 15 : datenum(date_e)
    str = sprintf('%s;%s', datestr(i, 'yyyy-mm-dd'), param);
    [data, obj.err.code, errmsg, ~, ~, ~]=THS_DP('block', str,'thscode:Y','format:array');
    if (obj.err.code)
        obj.err.msg = errmsg{:};
        obj.DispErr('Fetching option chain error when loading symbols');
        ins = ins_local;
        is_err = true;
        return;
    end
    symbols = union(symbols, data);
end
symbols = cellfun(@(x) {[x, ',']}, symbols');
symbols = [symbols{:}];
symbols(end) = [];

% 提取数据
[data, obj.err.code, ~,thscode, errmsg, ~, ~, ~] = THS_BD(symbols,'ths_option_short_name_option;ths_contract_type_option;ths_strike_price_option;ths_contract_multiplier_option;ths_listed_date_option;ths_maturity_date_option', ...
    sprintf(';;%s;;;', datestr(now(), 'yyyy-mm-dd')),'format:array');

% 输出
if (obj.err.code)
    obj.err.msg = errmsg{:};
    obj.DispErr('Fetching option chain failure');
    ins = ins_local;
    is_err = true;
    
else
    % 整理数据
    ins = [thscode, data];
    if (~isempty(ins))
        % 修正新信息
        for i = 1 : size(ins, 1)
            tmp = ins{i, 1};
            loc = strfind(tmp, '.');
            ins{i, 1} = tmp(1 : loc - 1);
        end
        ins(strcmpi(ins(:, 3), '看涨期权'), 3) = deal({'Call'});
        ins(strcmpi(ins(:, 3), '看跌期权'), 3) = deal({'Put'});
        ins(:, 6) = cellfun(@(x) {datestr(Utility.DatetimeOffset(datenum(num2str(x), 'yyyymmdd'), opt_s.tradetimetable(1)), 'yyyy-mm-dd HH:MM')}, ins(:, 6));
        ins(:, 7) = cellfun(@(x) {datestr(Utility.DatetimeOffset(datenum(num2str(x), 'yyyymmdd'), opt_s.tradetimetable(end)), 'yyyy-mm-dd HH:MM')}, ins(:, 7));
        ins(:, 8) = num2cell(str2double(cellstr(datestr(ins(:, 7), 'yyyymm'))));
        
        % 补全信息
        exc = upper(Utility.ToString(opt_s.exchange));
        var = char(opt_s.variety);
        ud_symb = char(opt_s.GetUnderSymbol());
        ud_product = upper(char(opt_s.GetUnderProduct()));
        ud_exc = upper(char(opt_s.GetUnderExchange()));
        striketype = Utility.InitCapital(Utility.ToString(opt_s.strike_type));
        ticksz = opt_s.tick_size;
        sttmode = Utility.InitCapital(Utility.ToString(opt_s.settle_mode));
        upd_time = datestr(now(), 'yyyy-mm-dd HH:MM');
        info = {exc, var, ud_symb, ud_product, ud_exc,  striketype, ticksz, sttmode, upd_time};
        info = repmat(info, size(ins, 1), 1);
        
        ins = [ins(:, 1 : 2), info(:, 1 : 5), ins(:, 3), info(:, 6), ins(:, 4 : 5), info(:, 7), ins(:, [8, 6, 7]), info(:, 8 : 9)];
        ins = cell2table(ins, 'VariableNames', {'SYMBOL','SEC_NAME','EXCHANGE','VARIETY','UD_SYMBOL','UD_PRODUCT','UD_EXCHANGE','CALL_OR_PUT','STRIKE_TYPE','STRIKE','SIZE','TICK_SIZE','DLMONTH','START_TRADE_DATE','END_TRADE_DATE','SETTLE_MODE','LAST_UPDATE_DATE'});
        
        % 合并
        if (~isempty(ins_local))
            [~, loc] = intersect(ins_local(:, 1), ins(:, 1));
            ins_local(loc, :) = [];
            ins = [ins_local; ins];
        end
        ins = sortrows(ins, 1);
        
    else
        ins = ins_local;
    end
    is_err = false;
    
end
end
