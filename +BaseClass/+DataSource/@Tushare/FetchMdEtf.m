% iFinD 获取ETF数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdEtf(obj, symb, exc, inv, ts_s, ts_e)

exc = obj.exchanges(Utility.ToString(exc));
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb,  exc, 1, ts_s, ts_e,  'Fetching etf [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, 5, ts_s, ts_e, 'Fetching etf [%s.%s] minitue market data');
        
    case EnumType.Interval.day        
        [is_err_a, nv] = obj.FetchDailyMd(symb, exc, ts_s, ts_e, 'fund_nav', {'nav_date', 'unit_nav', 'adj_nav'}, 'Fetching eft [%s%s] net value data');
        [is_err_b, md] = obj.FetchDailyMd(symb, exc, ts_s, ts_e, 'fund_daily', {'trade_date', 'open', 'high', 'low', 'close', 'amount', 'vol'}, 'Fetching eft [%s%s] net value data');
        if (~isempty(nv) && ~isempty(md))
            is_err = is_err_a | is_err_b;
            md = [nv, md(:, 2 : end)];
        end
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end