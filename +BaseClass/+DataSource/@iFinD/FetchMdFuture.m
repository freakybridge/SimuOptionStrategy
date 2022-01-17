% iFinD ��ȡ�ڻ���������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchMdFuture(obj, symb, exc, inv, ts_s, ts_e)

exc = obj.exchanges(EnumType.Exchange.ToString(exc));
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc, 1, ts_s, ts_e,  'Fetching future [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, 5, ts_s, ts_e, 'Fetching future [%s.%s] minitue market data');
        
    case EnumType.Interval.day
        [is_err, md] = obj.FetchDailyMd(symb, exc, ts_s, ts_e, ...
            'open, high, low, close, amt, volume, oi, dealnum, pre_settle, settle, st_stock', ...
            'Fetching future [%s.%s] daily market data');
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end