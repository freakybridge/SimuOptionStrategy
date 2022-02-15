% Tushare 获取分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMd(obj, symb, exc, inv, ts_s, ts_e, err_fmt)

md = obj.api.query('pro_bar', 'ts_code', [symb, exc], 'freq',  sprintf('%imin', inv), ...
    'start_date', datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), ...
    'end_date',  datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'));

% 输出检查
if (isempty(md))
    obj.err.msg = errmsg{:};
    obj.DispErr(sprintf(err_fmt, symb, exc));
    md = [];
    is_err = true;
else
    md(isnan(md)) = 0;
    md = [datenum(dt), md];
    is_err = false;
end

end

