% Wind 获取分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMd(obj, asset, ts_s, ts_e, err_fmt)

% 确定是否数据超限
if (datenum(ts_s) < now - obj.FetchApiDateLimit())
    md = [];
    is_err = false;
    return;
end

% 参数修正
exc = obj.exchanges(EnumType.Exchange.ToString(asset.exchange));
switch asset.interval
    case EnumType.Interval.min1
        inv = '1';
    case EnumType.Interval.min5
        inv = '5';
    otherwise
        error('Unexpected interval for [%s.%s] minute md fetching', asset.symbol, exc)
end


% 下载
[md, ~, ~, dt, obj.err.code, ~] = obj.api.wsi([asset.symbol, '.', exc], 'open,high,low,close,amt,volume,oi', ...
    datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%s',  inv));

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

