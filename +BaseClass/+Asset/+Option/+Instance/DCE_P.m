% DCE_P 期权类
% v1.3.0.20220113.beta
%       1.首次添加
classdef (Sealed) DCE_P < BaseClass.Asset.Option.Future
        
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.DCE;
        variety char = 'P';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 0.5;
        date_ini char = '2021-06-18';
    end
    
    % 父类Option属性
    properties (Constant)
        strike_type EnumType.OptionStrikeType = EnumType.OptionStrikeType.American;
        settle_mode EnumType.OptionSettleMode = EnumType.OptionSettleMode.Physical;
    end
    
    % 构造函数
    methods
        function obj = DCE_P(varargin)
            obj = obj@BaseClass.Asset.Option.Future('P', EnumType.Exchange.DCE, varargin{:});
        end
    end
    
end
