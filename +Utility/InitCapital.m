% ����ĸ��д����const char���
% v1.2.0.20220105.beta
%       �״����
function ret= InitCapital(in_)

if (isa(in_, 'cell'))
    in_ = in_{:};
end

ret = lower(char(in_));
ret = [upper(ret(1)), ret(2 : end)];
end