% Wind ��ȡ��Ȩ��������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchMdOption(obj, symb, exc, inv, ts_s, ts_e)
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc, '1', ts_s, ts_e,  'Fetching option [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, '5', ts_s, ts_e, 'Fetching option [%s.%s] minitue market data');
        
    case EnumTYpe.Interval.day
        error('123');
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end