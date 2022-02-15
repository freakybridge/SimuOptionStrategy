% JoinQuant ��ȡ������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, fields, err_fmt)

% ����
exc = obj.exchanges(Utility.ToString(exc));
[md, ~, ~, dt, obj.err.code, ~] = obj.api.wsd([symb, '.', exc], fields, ...
    datestr(ts_s, 'yyyy-mm-dd'), datestr(ts_e, 'yyyy-mm-dd'));

% ���
if (obj.err.code)
    obj.err.msg = md{:};
    obj.DispErr(sprintf(err_fmt, symb, exc));
    md = [];
    is_err = true;
else
    md = [dt, md];
    is_err = false;
end
end