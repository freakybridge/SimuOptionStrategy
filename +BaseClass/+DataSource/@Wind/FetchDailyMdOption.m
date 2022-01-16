% Wind ��ȡ��Ȩ������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchOptionDayData(obj, opt, ts_s, ts_e)

% ����
exc = obj.exchanges(EnumType.Exchange.ToString(opt.exchange));
[md, ~, ~, dt, obj.err.code, ~] = obj.api.wsd([opt.symbol, '.', exc], 'open,high,low,close,amt,volume,oi, ptmday, ptmtradeday', ...
    datestr(ts_s, 'yyyy-mm-dd'), datestr(ts_e, 'yyyy-mm-dd'));

% ���
if (obj.err.code)
    obj.err.msg = md{:};
    obj.DispErr(sprintf('Fetching option %s daily market data', opt.symbol));
    md = [];
    is_err = true;
else
    md = [dt, md];
    is_err = false;
end
end