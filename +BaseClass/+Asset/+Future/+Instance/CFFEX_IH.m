% IH FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) CFFEX_IH < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CFFEX;
        variety char = 'IH';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.2;
        date_ini char = '2015/04/16';
    end
    
    % ���캯��
    methods
        function obj = CFFEX_IH(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end