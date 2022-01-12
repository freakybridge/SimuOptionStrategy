% const char
% v1.2.0.20220105.beta
%       首次添加
function ret = Trans2Str(in_)

% 取数据
if (isa(in_, 'cell'))
    in_ = in_{:};
end

% 转换
if (isa(in_, 'double'))
    ret = num2str(in_);
else
    ret = in_;
end
end