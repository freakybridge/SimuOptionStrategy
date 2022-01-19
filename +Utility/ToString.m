% 其他类型转换字符串
% v1.3.0.20220113.beta
%       首次添加
function ret = ToString(in_)

% 取数据
if (isa(in_, 'cell'))
    in_ = in_{:};
end

% 转换
class_in = class(in_);
if ismember(class_in, {'float', 'double', 'int8', 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'uint64'})
    ret = num2str(in_);
    
elseif ismember(class_in, {'char'})
    ret = in_;
    
elseif ismember(class_in, {'string'})
    ret = char(in_);
    
elseif contains(class_in, 'EnumType')
    ret = sprintf('%s.ToString(in_)', class_in);
    ret = eval(ret);
    
else
    error('Unexpected condition, please check.');
end
end