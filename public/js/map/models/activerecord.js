var iterateFields=function(fields,funct){
  for(var i=0,l=fields.length;i<l;i++){ funct(i,fields[i]);};
};

var update_values=function(model,fields,values){
  if(values){
    iterateFields(fields,function(index,fieldName){
      var value=values[fieldName];
      if (typeof value!=='undefined'){ model[fieldName]=value; }
    });
  }
  return model;
};

exports.extend=function(fields){
  return {
    update_values:function(values){
      return update_values(this,fields,values);
    },
    dump:function(){
      iterateFields(fields,function(index,fieldName){
        console.log(fieldName+': ' + this[fieldName]);
      });
    },
  };
};