var html=require('../html')
  , button=require('../button')
  ;

module.exports=function(fields,opts){
  var _model={}
    , _fields=fields||[]
    , _form=html.el('div')
    , _toolbar=button.toolbar()
    ;

  // place fields

  for(var i=0, l=_fields.length; i<l; i++){
    var f=_fields[i];
    _form.appendChild(f);
  }

  // model fields

  _form.getModel=function(){
    return _model;
  }

  _form.setModel=function(model){
    _model=model;
  };

  // actions

  _form.appendChild(_toolbar);
  var actions=opts&&opts.actions;
  if (actions){
    for(var i=0,l=actions.length;i<l;i++){
      var action=actions[i];
      var btn=button.actionButton(action.label,action.action,{icon:action.icon, type:action.type});
      _toolbar.addButton(btn);
    }
  }

  return _form;
};
