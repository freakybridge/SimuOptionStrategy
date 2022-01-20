% ��С100ָ��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SZSE_399005< BaseClass.Asset.Index.Index
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SZSE;
        variety char = '399005';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.01;
        date_ini char = '2006/01/24';
    end
    
    methods
        function obj = SZSE_399005(varargin)
            obj = obj@BaseClass.Asset.Index.Index('399005', '��С100ָ��', varargin{:}, 1);
        end
    end
end

