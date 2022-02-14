% Tushare 获取分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMd(obj, symb, exc, inv, ts_s, ts_e, err_fmt)

% 获取时限检查
if (datenum(ts_s) < now - obj.FetchApiDateLimit())
    md = [];
    is_err = false;
    return;
end

% 下载
[md, obj.err.code, dt, ~,~, errmsg, ~, ~] = THS_HF([symb, '.', exc], 'open;high;low;close;amount;volume;openInterest',...
    sprintf('Fill:Previous,Interval:%i',  inv), ...
    datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), ...
    'format:matrix');

% 输出检查
if (obj.err.code)
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

