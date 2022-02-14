% Tushare 获取期权合约列表
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, ins] = FetchChainOption(obj, opt_s, ins_local)

% 获取下载起点终点
[date_s, date_e] = obj.GetChainUpdateSE(opt_s, ins_local);

% 下载全部合约
res = obj.api.query('opt_basic', 'exchange', Utility.ToString(opt_s.exchange));
if (isempty(res))
    obj.err.code = -1;
    obj.err.msg = 'Fetching option chain failure';
    obj.DispErr('Fetching option chain failure');
    ins = ins_local;
    is_err = true;
    return;
end

% 整理数据    
res = res(contains(res.opt_code, sprintf('OP%s', opt_s.variety)), :);
ins = cell(height(res), 5);
ins(:, 1) = res.ts_code;
ins(:, 2) = res.name;
ins(:, 3) = res.call_put;
ins(strcmpi(ins(:, 3), 'C'), 3) = deal({'Call'});
ins(strcmpi(ins(:, 3), 'P'), 3) = deal({'Put'});
ins(:, 4) = num2cell(res.exercise_price);
ins(:, 5) = num2cell(res.per_unit);
ins(:, 6) = cellfun(@(x) {datestr(Utility.DatetimeOffset(datenum(num2str(x), 'yyyymmdd'), opt_s.tradetimetable(1)), 'yyyy-mm-dd HH:MM')}, res.list_date);
ins(:, 7) = cellfun(@(x) {datestr(Utility.DatetimeOffset(datenum(num2str(x), 'yyyymmdd'), opt_s.tradetimetable(end)), 'yyyy-mm-dd HH:MM')}, res.delist_date);
ins(:, 8) = num2cell(cellfun(@(x) str2double(datestr(x, 'yyyymm')), ins(:, 7)));

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
is_err = false;

end
