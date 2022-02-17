% Tushare 获取指数行情数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e)

exc = obj.exchanges(Utility.ToString(exc));
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc, 1, ts_s, ts_e,  'Fetching index [%s%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, 5, ts_s, ts_e, 'Fetching index [%s%s] minitue market data');
        
    case EnumType.Interval.day        
        [is_err, md] = obj.FetchDailyMd(symb, exc, ts_s, ts_e, 'index_daily', {'trade_date', 'open', 'high', 'low', 'close', 'vol', 'amount'}, 'Fetching index [%s%s] daily market data');
        
        % 修正成交量 / 成交额
        if (~is_err)
            md(:, 6) = md(:, 6) * 100;
            md(:, 7) = md(:, 7) * 1000;
        end
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end