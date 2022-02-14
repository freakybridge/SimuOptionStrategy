% iFinD ��ȡ������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, fields, params, err_fmt)

% ����
[md, obj.err.code, dt, ~, ~, obj.err.msg, ~] = THS_DS([symb, '.', exc], fields, params, ...
    'block:latest', ...
    datestr(ts_s, 'yyyy-mm-dd'), ...
    datestr(ts_e, 'yyyy-mm-dd'), ...
    'format:array' ...
    );

% ���
if (obj.err.code)
    obj.err.msg = obj.err.msg{:};
    obj.DispErr(sprintf(err_fmt, symb, exc));
    md = [];
    is_err = true;
else
    if (isa(md, 'cell'))
        md = cell2mat(md);
    end
    md(isnan(md)) = 0;
    md = [datenum(dt), md];
    is_err = false;
end
end