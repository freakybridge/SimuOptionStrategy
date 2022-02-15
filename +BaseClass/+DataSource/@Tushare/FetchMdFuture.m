% Tushare 获取期货行情数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdFuture(obj, symb, exc_i, inv, ts_s, ts_e)

exc_tmp = obj.exchanges(Utility.ToString(exc_i));
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc_tmp, 1, ts_s, ts_e,  'Fetching future [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc_tmp, 5, ts_s, ts_e, 'Fetching future [%s.%s] minitue market data');
        
    case EnumType.Interval.day
        [is_err, md] = obj.FetchDailyMd(symb, exc_tmp, ts_s, ts_e, 'fut_daily', {'trade_date', 'open', 'high', 'low', 'close', 'amount', 'vol', 'oi', 'pre_settle', 'settle'}, 'Fetching future [%s%s] daily market data');
        if (~isempty(md) && exc_i ~= EnumType.Exchange.CFFEX)            
            symb = regexp(symb, '\D*', 'match');
            symb = symb{:};
            for i = 1 : size(md, 1)
                res = obj.api.query('fut_wsr', 'trade_date', datestr(md(i, 1), 'yyyymmdd'), 'symbol', symb);
                md(i, 11) = res.vol;
            end            
        end
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end