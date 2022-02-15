% JoinQuant 获取日数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, fields, err_fmt)

% 下载
exc = obj.exchanges(Utility.ToString(exc));
[md, ~, ~, dt, obj.err.code, ~] = obj.api.wsd([symb, '.', exc], fields, ...
    datestr(ts_s, 'yyyy-mm-dd'), datestr(ts_e, 'yyyy-mm-dd'));

% 输出
if (obj.err.code)
    obj.err.msg = md{:};
    obj.DispErr(sprintf(err_fmt, symb, exc));
    md = [];
    is_err = true;
else
    md = [dt, md];
    is_err = false;
end
end