% 159919 ETF��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SZSE_159919 < BaseClass.Asset.ETF.ETF
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SZSE;
        variety char = '159919';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.001;
        date_ini char = '2012/05/07';
    end
    
    % ����ETF����
    properties (Constant)
        divlst cell = [ ...
            {'2020/08/16'}, {0.0700}; ...
            {'2021/09/13'}, {0.1520}; ...
            ];
    end
    
    % ���캯��
    methods
        function obj = SZSE_159919(inv)
            obj = obj@BaseClass.Asset.ETF.ETF('510300', '��ʵ����300ETF', inv, 100);
        end
    end
    
end
