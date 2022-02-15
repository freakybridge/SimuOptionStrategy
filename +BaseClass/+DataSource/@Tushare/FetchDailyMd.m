% Tushare ��ȡ������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchDailyMd(obj, symb, exc, ts_s, ts_e, func, fields, err_fmt)

% ����
res = obj.api.query(func, 'ts_code', sprintf('%s%s', symb, exc), 'start_date', datestr(ts_s, 'yyyymmdd'), 'end_date', datestr(ts_e, 'yyyymmdd'));

% ���
if (isempty(res))
    obj.err.msg = 'dailiy queto fetching error';
    obj.DispErr(sprintf(err_fmt, symb, exc));
    md = [];
    is_err = true;
else
    md = zeros(height(res), length(fields));
    for i = 1 : length(fields)
        if (i ~= 1)
            md(:, i) = res.(fields{i});
        else
            md(:, i) = datenum(res.(fields{i}), 'yyyymmdd');
        end
    end
    is_err = false;
end
end