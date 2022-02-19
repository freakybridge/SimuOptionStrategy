% JoinQuant 获取期权合约列表
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, ins] = FetchChainOption(obj, opt_s, ins_local)
% 获取下载起点终点
% [date_s, date_e] = obj.GetChainUpdateSE(opt_s, ins_local);

% fetch
ud_symb = sprintf('%s.%s', opt_s.GetUnderSymbol(), obj.exchanges(Utility.ToString(opt_s.GetUnderExchange())));
[is_err, obj.err.code, obj.err.msg, ins] = obj.AnalysisApiResult(py.api.fetch_option_chain(obj.user, obj.password, ud_symb));
if (is_err)
    fprintf('%s ERROR: Fetching calendar trade day error, [code: %d] [msg: %s], please check. \r', obj.name, obj.err.code, obj.err.msg);
end

% repair infomation
for i = 1 : size(ins, 1)
    tmp = ins{i, 1};
    loc = strfind(tmp, '.');
    ins{i, 1} = tmp(1 : loc - 1);
end
ins(strcmpi(ins(:, 3), 'CO'), 3) = deal({'Call'});
ins(strcmpi(ins(:, 3), 'PO'), 3) = deal({'Put'});
ins(:, 6) = cellstr(datestr(Utility.DatetimeOffset(datenum(ins(:, 6)), opt_s.tradetimetable(1)), 'yyyy-mm-dd HH:MM'));
ins(:, 7) = cellstr(datestr(Utility.DatetimeOffset(datenum(ins(:, 7)), opt_s.tradetimetable(end)), 'yyyy-mm-dd HH:MM'));
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
end
