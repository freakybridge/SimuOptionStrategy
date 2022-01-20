% ��ָ֤��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SSE_000001 < BaseClass.Asset.Index.Index
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '000001';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.01;
        date_ini char = '1990/12/19';
    end
    
    methods
        function obj = SSE_000001(varargin)
            obj = obj@BaseClass.Asset.Index.Index('000001', '��ָ֤��', varargin{:}, 1);
        end
    end
end

