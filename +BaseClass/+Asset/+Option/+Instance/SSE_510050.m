% 510050 ��Ȩ��
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
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.European;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    properties
        underlying = BaseClass.Asset.ETF.Instance.SSE_510050('5m');
    end    
    
    % ���캯��
    methods
        function obj = SSE_510050(varargin)
            obj = obj@BaseClass.Asset.Option.ETF(varargin{:});
        end
    end
    
end

