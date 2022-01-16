% ����Դ�˿� WindApi
% v1.3.0.20220113.beta
%       1.����Source����
%       2.FetchXXX��������ȡ״̬
%       3.Error��ʾͳһ��
%       4.�����Ա����Լ��
% v1.2.0.20220105.beta
%       �״����
classdef Wind < BaseClass.DataSource.DataSource
    properties (Access = private)
        api windmatlab;
    end
    properties (Constant)
        name char = 'Wind';
    end
    properties (Hidden)        
        exchanges containers.Map;
    end
    
    methods
        % ���캯��
        function obj = Wind()
            %WIND ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.DataSource.DataSource();
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SSE)) = 'SH';
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SZSE)) = 'SZ';       
            
            % ��¼
            obj.api = windmatlab;
            if (obj.api.isconnected())
                fprintf('DataSource %s Ready.\r', obj.name);
            end
        end                
    end
    
    methods (Static)
        % ��ȡapi����ʱ��
        function ret = FetchApiDateLimit()
            ret = 3 * 365;
        end
    end
    
    
    methods (Hidden)
        function ret= IsErrFatal(obj)
            if (obj.err.code)
                ret = true;
            else
                ret = false;
            end
        end
    end
    
end

