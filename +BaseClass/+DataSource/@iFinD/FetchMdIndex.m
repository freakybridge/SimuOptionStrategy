% Wind 获取指数行情数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e)
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc, '1', ts_s, ts_e,  'Fetching index [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, '5', ts_s, ts_e, 'Fetching index [%s.%s] minitue market data');
        
    case EnumType.Interval.day
        [is_err, md] = obj.FetchDailyMd(symb, exc, ts_s, ts_e, ...
            'open,high,low,close,amt, volume', ...
            'Fetching index [%s.%s] daily market data');
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end