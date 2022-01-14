% ����300ָ��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SSE_000300< BaseClass.Asset.Index.Index
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '000300';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.01;
        date_ini char = '2005/01/04';
    end
    
    methods
        function obj = SSE_000300(inv)
            obj = obj@BaseClass.Asset.Index.Index('000300', '����300ָ��', inv, 1);
        end
    end
end

