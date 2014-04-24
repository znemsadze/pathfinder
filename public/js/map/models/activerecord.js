var iterateFields=function(fields,funct){
  for(var i=0,l=fields.length;i<l;i++){ funct(i,fields[i]);};
};

var update_attributes=function(model,fields,values){
  if(values){
    iterateFields(fields,function(index,fieldName){
      var value=values[fieldName];
      if (typeof value!=='undefined'){ model[fieldName]=value; }
    });
  }
  return model;
};

exports.extend=function(fields){
  var object={};
  object.update_attributes=function(values){
    return update_attributes(object,fields,values);
  };
  object.dump=function(){
    iterateFields(fields,function(index,fieldName){
      console.log(fieldName+': ' + object[fieldName]);
    });
  };
  return object;
};