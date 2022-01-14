% ��֤500ָ��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SSE_000905< BaseClass.Asset.Index.Index
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '000905';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.01;
        date_ini char = '2007/01/15';
    end
    
    methods
        function obj = SSE_000905(inv)
            obj = obj@BaseClass.Asset.Index.Index('000905', '��֤500ָ��', inv, 1);
        end
    end
end

