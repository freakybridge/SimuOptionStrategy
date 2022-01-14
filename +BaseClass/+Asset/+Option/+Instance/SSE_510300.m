% 510300����
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
%       2.���Ա�ع�
% v1.2.0.20220105.beta
%       �״����
classdef (Sealed) SSE_510300 < BaseClass.Asset.Option.ETF
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '510300';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.0001;
        date_ini char = '2019-12-23';
    end
    
    % ����Option����
    properties (Constant)
        ud_symbol char = "510300";
        ud_exchange EnumType.Exchange = EnumType.Exchange.SSE;
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.European;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    
    % ����ETF����
    properties (Constant)
        divlst cell = [ ...
            {'2021/01/18'}, {0.072}; ...
            ];
    end
    
    % ���캯��
    methods
        function obj = SSE_510300(symb, snm, inv, sz, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Option.ETF(symb, snm, inv, sz, cop, k, ldt, edt);
        end
    end
    
end
