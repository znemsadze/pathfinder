var html=require('../html')
  ;

module.exports=function(model,fields,opts){
  var _model=model||{}
    , _fields=fields||[]
    , form=html.el('div')
    ;

  for(var i=0, l=_fields.length; i<l; i++){
    var f=_fields[i];
    form.appendChild(f);
  }

  var getModel=function(){
    return _model;
  }

  var setModel=function(model){
    _model=model;
  };

  form.getModel=getModel;
  form.setModel=setModel;
  return form;
};
