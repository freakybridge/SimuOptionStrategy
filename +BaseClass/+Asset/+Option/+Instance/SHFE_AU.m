% SHFE_AU 期权类
% v1.3.0.20220113.beta
%       1.首次添加
classdef (Sealed) SHFE_AU < BaseClass.Asset.Option.Future
        
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SHFE;
        variety char = 'AU';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 230]];
        tick_size double = 0.02;
        date_ini char = '2019-12-20';
    end
    
    % 父类Option属性
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.American;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    
    % 构造函数
    methods
        function obj = SHFE_AU(varargin)
            obj = obj@BaseClass.Asset.Option.Future('AU', EnumType.Exchange.SHFE, varargin{:});
        end
    end
    
end
