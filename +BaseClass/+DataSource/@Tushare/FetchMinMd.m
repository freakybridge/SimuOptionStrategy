% Tushare 获取分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMd(obj, symb, exc, inv, ts_s, ts_e, err_fmt)

res = obj.api.query('pro_bar', 'ts_code', [symb, exc], 'freq',  sprintf('%imin', inv), ...
    'start_date', datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), ...
    'end_date',  datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'));

% 输出检查
if (isempty(res))
    obj.err.code = -1;
    obj.err.msg = sprintf(err_fmt, symb, exc);
    obj.DispErr(sprintf(err_fmt, symb, exc));
    md = [];
    is_err = true;
else
    dt = datenum(res.trade_date);
    open = res.open;
    high = res.high;
    low = res.low;
    last = res.close;
    turnover = zeros(size(open, 1), 1);
    vol = res.vol;
    oi = zeros(size(open, 1), 1);    
    md = [dt, open, high, low, last, turnover, vol, oi];
    is_err = false;
end
end

