% Wind ��ȡ��Ȩ��������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchOptionMinData(obj, opt, ts_s, ts_e, inv)
% ȷ���Ƿ����ݳ���
if (datenum(opt.GetDateListed()) < now - obj.FetchApiDateLimit())
    md = [];
    is_err = false;
    return;
end

% ����
exc = obj.exchanges(EnumType.Exchange.ToString(opt.exchange));
[md, ~, ~, dt, obj.err.code, ~] = obj.api.wsi([opt.symbol, '.', exc], 'open,high,low,close,amt,volume,oi', ...
    datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%i',  inv));

% ���
if (obj.err.code)
    obj.err.msg = md{:};
    obj.DispErr(sprintf('Fetching option %s market data', opt.symbol));
    md = [];
    is_err = true;
else
    md = [dt, md];
    is_err = false;
end
end