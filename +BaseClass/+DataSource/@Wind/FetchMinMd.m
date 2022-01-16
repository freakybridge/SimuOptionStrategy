% Wind 获取分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMd(obj, asset, ts_s, ts_e, inv, err_fmt)

% 确定是否数据超限
if (datenum(ts_s) < now - obj.FetchApiDateLimit())
    md = [];
    is_err = false;
    return;
end

% 下载
exc = obj.exchanges(EnumType.Exchange.ToString(asset.exchange));
[md, ~, ~, dt, obj.err.code, ~] = obj.api.wsi([asset.symbol, '.', exc], 'open,high,low,close,amt,volume,oi', ...
    datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%i',  inv));

% 输出
if (obj.err.code)
    obj.err.msg = md{:};
    obj.DispErr(sprintf(err_fmt, asset.symbol, exc));
    md = [];
    is_err = true;
else
    md = [dt, md];
    is_err = false;
end

end

