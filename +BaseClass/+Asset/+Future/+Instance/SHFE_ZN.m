% ZN FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) SHFE_ZN < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.SHFE;
        variety char = 'ZN';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 100]];
        tick_size double = 5;
        date_ini char = '2007/03/26';
    end
    
    % ���캯��
    methods
        function obj = SHFE_ZN(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end