exports.isArray=function(x){ return x && (x instanceof Array); };
exports.isElement=function(x){ return x && ((x instanceof Element) || (x instanceof Document)); }
exports.fieldValue=function(object,name){ return object&&object[name]; };