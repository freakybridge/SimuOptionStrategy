% ��֤��ָ
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SZSE_399001< BaseClass.Asset.Index.Index
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SZSE;
        variety char = '399001';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.01;
        date_ini char = '1991/04/03';
    end
    
    methods
        function obj = SZSE_399001(varargin)
            obj = obj@BaseClass.Asset.Index.Index('399001', '��֤��ָ', varargin{:}, 1);
        end
    end
end

