% iFinD 获取日数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, fields, params, err_fmt)

% 下载
[md, obj.err.code, dt, ~, ~, obj.err.msg, ~] = THS_DS([symb, '.', exc], fields, params, ...
    'block:latest', ...
    datestr(ts_s, 'yyyy-mm-dd'), ...
    datestr(ts_e, 'yyyy-mm-dd'), ...
    'format:array' ...
    );

% 输出
if (obj.err.code)
    obj.err.msg = obj.err.msg{:};
    obj.DispErr(sprintf(err_fmt, symb, exc));
    md = [];
    is_err = true;
else
    if (isa(md, 'cell'))
        md = cell2mat(md);
    end
    md(isnan(md)) = 0;
    md = [datenum(dt), md];
    is_err = false;
end
end