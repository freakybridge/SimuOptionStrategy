% INE_SC ��Ȩ��
% v1.3.0.20220113.beta
%       1.�״����
classdef (Sealed) INE_SC < BaseClass.Asset.Option.Future
        
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.INE;
        variety char = 'SC';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 230]];
        tick_size double = 0.05;
        date_ini char = '2021-06-21';
    end
    
    % ����Option����
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.American;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    
    % ���캯��
    methods
        function obj = INE_SC(varargin)
            obj = obj@BaseClass.Asset.Option.Future('SC', EnumType.Exchange.INE, varargin{:});
        end
    end
    
end
