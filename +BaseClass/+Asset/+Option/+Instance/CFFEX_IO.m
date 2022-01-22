% CFFEX_IO ��Ȩ��
% v1.3.0.20220113.beta
%       1.�״����
classdef (Sealed) CFFEX_IO < BaseClass.Asset.Option.Index
        
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CFFEX;
        variety char = 'IO';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.2;
        date_ini char = '2019-12-23';
    end
    
    % ����Option����
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.European;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Cash;
    end
    
    % ���캯��
    methods
        function obj = CFFEX_IO(varargin)
            obj = obj@BaseClass.Asset.Option.Index('000300', EnumType.Exchange.SSE, varargin{:});
        end
    end
    
end
