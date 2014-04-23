var update_values=function(object,fields,values){
  for(var i=0,l=fields.length;i<l;i++){
    var fieldName=fields[i];
    var value=values[fieldName];
    if (typeof value !== 'undefined'){

      object[fieldName]=value;
    }
  }
};

exports.extend=function(fields){
  var iterateFields=function(funct){
    for(var i=0,l=fields.length;i<l;i++){
      funct(i,fields[i]);
    }
  };
  return {
    update_values:function(values){
      if(values){
        iterateFields(function(index,fieldName){
          var value=values[fieldName];
          if (typeof value !== 'undefined') { this[fieldName]=value; }
        });
      }
      return this;
    },
    dump:function(){
      iterateFields(function(index,fieldName){
        console.log(fieldName+': ' + this[fieldName]);
      });
    },
  };
};