% 510050����
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
%       2.���Ա�ع�
% v1.2.0.20220105.beta
%       �״����
classdef (Sealed) SSE_510050 < BaseClass.Asset.Option.ETF 
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SSE;
        variety char = '510050';
        tradetimetable double = [[930, 1130]; [1300, 1500]];        
        tick_size double = 0.0001;
        date_ini char = '2015-02-09';
    end
        
    % ����Option����
    properties (Constant)
        ud_symbol char = "510050";
        ud_exchange EnumType.Exchange = EnumType.Exchange.SSE;
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.European;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    
    % ����ETF����
    properties (Constant)
        divlst cell = [ ...
            {'2016/11/29'}, {0.053}; ...
            {'2017/11/28'}, {0.054}; ...
            {'2018/12/03'}, {0.049}; ...
            {'2019/12/02'}, {0.047}; ...
            {'2020/11/30'}, {0.051}; ...
            {'2021/11/29'}, {0.041}; ...
            ];
    end
    
    % ���캯��
    methods
        function obj = SSE_510050(symb, snm, inv, sz, cop, k, ldt, edt)
            obj = obj@BaseClass.Asset.Option.ETF(symb, snm, inv, sz, cop, k, ldt, edt);
        end
    end
    
end

