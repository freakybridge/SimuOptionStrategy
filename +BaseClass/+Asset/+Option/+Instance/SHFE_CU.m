% SHFE_CU 期权类
% v1.3.0.20220113.beta
%       1.首次添加
classdef (Sealed) SHFE_CU < BaseClass.Asset.Option.Future
        
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SHFE;
        variety char = 'CU';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 100]];
        tick_size double = 2;
        date_ini char = '2018-09-21';
    end
    
    % 父类Option属性
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.American;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    
    % 构造函数
    methods
        function obj = SHFE_CU(varargin)
            obj = obj@BaseClass.Asset.Option.Future('CU', EnumType.Exchange.SHFE, varargin{:});
        end
    end
    
end
