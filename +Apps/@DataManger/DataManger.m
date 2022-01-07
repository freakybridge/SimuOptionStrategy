classdef DataManger
    % FORMATTRANSFER 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        Property1
    end
    
    methods
        function obj = DataManger()
        end
        
    end
    
    methods (Static)
        ret = TransferTaobaoExcel(dir_hm, dir_tb, dir_sav);        
        
        ret = Database2Md();
        ret = DataSource2Md();
        md = Csv2Md(dir_in, opt);
        
        ret = Md2Csv(dir_out, opt, md);
        ret = Md2Database(opt, db_);
    end
end

