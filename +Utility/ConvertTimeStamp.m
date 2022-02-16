% 转换时间戳格式
% v1.3.0.20220113.beta
%       首次加入
function [str, dm, dt, tm] = ConvertTimeStamp(dm)
str = cellstr(datestr(dm, 'yyyy-mm-dd HH:MM'));
tmp = datevec(dm);
dt = tmp(:, 1) * 10000 + tmp(:, 2) * 100 + tmp(:, 3);
tm = tmp(:, 4) * 10000 + tmp(:, 5) * 100 + tmp(:, 6);
end

