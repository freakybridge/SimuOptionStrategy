classdef BaseEnum
    methods (Abstract)
        ret = ToString(in_);
        ret = ToEnum(in_);
    end
end