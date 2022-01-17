% iFinD 获取ETF数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdEtf(obj, symb, ~, inv, ts_s, ts_e)

exc = 'OF';
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb,  exc, 1, ts_s, ts_e,  'Fetching etf [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, 5, ts_s, ts_e, 'Fetching etf [%s.%s] minitue market data');
        
    case EnumType.Interval.day
        [is_err, md] = obj.FetchDailyMd(symb, exc, ts_s, ts_e, ...
            'ths_unit_nv_fund;ths_adjustment_nv_fund;ths_open_price_fund;ths_high_price_fund;ths_low_fund;ths_close_price_fund;ths_amt_fund;ths_vol_fund', ...
            ';;100;100;100;100;;', ...
            'Fetching etf [%s.%s] daily market data');
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end