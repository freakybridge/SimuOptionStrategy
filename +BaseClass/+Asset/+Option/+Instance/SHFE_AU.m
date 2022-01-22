% SHFE_AU ��Ȩ��
% v1.3.0.20220113.beta
%       1.�״����
classdef (Sealed) SHFE_AU < BaseClass.Asset.Option.Future
        
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SHFE;
        variety char = 'AU';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 230]];
        tick_size double = 0.02;
        date_ini char = '2019-12-20';
    end
    
    % ����Option����
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.American;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    
    % ���캯��
    methods
        function obj = SHFE_AU(varargin)
            obj = obj@BaseClass.Asset.Option.Future('AU', EnumType.Exchange.SHFE, varargin{:});
        end
    end
    
end
