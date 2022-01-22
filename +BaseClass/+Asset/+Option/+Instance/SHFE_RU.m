% SHFE_RU ��Ȩ��
% v1.3.0.20220113.beta
%       1.�״����
classdef (Sealed) SHFE_RU < BaseClass.Asset.Option.Future
        
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SHFE;
        variety char = 'RU';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 1;
        date_ini char = '2019-01-28';
    end
    
    % ����Option����
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.American;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    
    % ���캯��
    methods
        function obj = SHFE_RU(varargin)
            obj = obj@BaseClass.Asset.Option.Future('RU', EnumType.Exchange.SHFE, varargin{:});
        end
    end
    
end