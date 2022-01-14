% 510300 ETF��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SSE_510300 < BaseClass.Asset.ETF.ETF
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '510300';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.001;
        date_ini char = '2012/05/04';
    end
    
    % ����ETF����
    properties (Constant)
        divlst cell = [ ...
            {'2021/01/18'}, {0.072}; ...
            ];
    end
    
    % ���캯��
    methods
        function obj = SSE_510300(inv)
            obj = obj@BaseClass.Asset.ETF.ETF('510300', '��̩������300ETF', inv, 100);
        end
    end
    
end

