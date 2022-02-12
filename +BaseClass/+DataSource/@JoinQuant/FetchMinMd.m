% Wind ��ȡ��������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchMinMd(obj, symb, exc, inv, ts_s, ts_e, err_fmt)

% ��ȡʱ�޼��
if (datenum(ts_s) < now - obj.FetchApiDateLimit())
    md = [];
    is_err = false;
    return;
end

% ����
exc = obj.exchanges(Utility.ToString(exc));
[md, ~, ~, dt, obj.err.code, ~] = obj.api.wsi([symb, '.', exc], 'open,high,low,close,amt,volume,oi', ...
    datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%i',  inv));

% ������
if (obj.err.code)
    obj.err.msg = md{:};
    obj.DispErr(sprintf(err_fmt, symb, exc));
    md = [];
    is_err = true;
else
    md(isnan(md)) = 0;
    md = [dt, md];
    is_err = false;
end

end

