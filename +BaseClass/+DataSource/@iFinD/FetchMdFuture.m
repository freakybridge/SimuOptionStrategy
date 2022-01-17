% iFinD 获取期货行情数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdFuture(obj, symb, exc, inv, ts_s, ts_e)

exc = obj.exchanges(EnumType.Exchange.ToString(exc));
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc, 1, ts_s, ts_e,  'Fetching future [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, 5, ts_s, ts_e, 'Fetching future [%s.%s] minitue market data');
        
    case EnumType.Interval.day        
        [is_err, md] = obj.FetchDailyMd(symb, exc, ts_s, ts_e, ...
            'ths_open_price_future;ths_high_price_future;ths_low_future;ths_close_price_future;ths_amt_future;ths_vol_future;ths_open_interest_future;ths_pre_settle_future;ths_settle_future;ths_reg_warehouse_receipts_num_future', ...
            ';;;;;;;;;', ...
            'Fetching future [%s.%s] daily market data');
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end