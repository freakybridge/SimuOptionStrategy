% PM FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) CZCE_PM < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'PM';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]];
        tick_size double = 1;
        date_ini char = '2008/03/24';
    end
    
    % ���캯��
    methods
        function obj = CZCE_PM(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end