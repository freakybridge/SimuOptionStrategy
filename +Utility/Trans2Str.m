% const char
% v1.2.0.20220105.beta
%       �״����
function ret = Trans2Str(in_)

% ȡ����
if (isa(in_, 'cell'))
    in_ = in_{:};
end

% ת��
if (isa(in_, 'double'))
    ret = num2str(in_);
else
    ret = in_;
end
end