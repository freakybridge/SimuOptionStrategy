% HC FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SHFE_HC < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SHFE;
        variety char = 'HC';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 1;
        date_ini char = '2014/03/21';
    end
    
    % ���캯��
    methods
        function obj = SHFE_HC(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end