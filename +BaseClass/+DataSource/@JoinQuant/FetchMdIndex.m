% JoinQuant 获取指数行情数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e)

% 预处理
ts_s = datestr(ts_s, 'yyyy-mm-dd HH:MM:SS');
ts_e = datestr(ts_e, 'yyyy-mm-dd HH:MM:SS');
cnt = obj.CalcFetchingRows(ts_s, ts_e, inv, exc);
exc = obj.exchanges(Utility.ToString(exc));

% 下载
switch inv
    case EnumType.Interval.min1
        [is_err, md] = FetchMin(obj, symb, exc, '1m', ts_s, ts_e, cnt, {'date', 'open', 'high', 'low', 'close', 'volume', 'money'}, 'Fetching index [%s.%s] minitue market data'); 
        
    case EnumType.Interval.min5
        [is_err, md] = FetchMin(obj, symb, exc, '5m', ts_s, ts_e, cnt, {'date', 'open', 'high', 'low', 'close', 'volume', 'money'}, 'Fetching index [%s.%s] minitue market data'); 
        
    case EnumType.Interval.day
        [is_err, obj.err.code, obj.err.msg, data] = obj.AnalysisApiResult(py.api.fetch_day_index_bar(obj.user, obj.password, symb, exc, ts_s, ts_e));
        if (~is_err)
            md = [datenum(data(:, 1)), cell2mat(data(:, 2 : end))];
        else
            md = [];
            obj.DispErr(sprintf('Fetching index [%s.%s] daily market data', symb, exc));
        end
        
    otherwise
        error('Unexpected "interval" for [%s] market data fetching, please check.', symb);
end
end


