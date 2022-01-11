% 时点偏移计算
% v1.2.0.20220105.beta
%       首次添加
function ret = DatetimeOffset(in_, offset)
h = floor(offset / 100);
m = offset - h * 100;
offset = (h * 60 + m) / 24 / 60;

ret = datenum(in_) + offset;
end