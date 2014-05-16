var html=require('../html')
  , button=require('../button')
  ;

module.exports=function(fields,opts){
  var _model={}
    , _fields=fields||[]
    , _form=html.el('div',{class:'form'})
    , _toolbar=button.toolbar()
    ;

  // place fields

  for(var i=0, l=_fields.length; i<l; i++){
    var f=_fields[i];
    _form.appendChild(f);
  }

  // model fields

  _form.getModel=function(){
    for(var i=0, l=_fields.length; i<l; i++){
      _fields[i].applyModel(_model);
    }
    _model.errors={};
    return _model;
  }

  _form.setModel=function(model){
    for(var i=0, l=_fields.length; i<l; i++){
      var fld=_fields[i];
      fld.setModel(model);
      if(typeof fld.redisplay === 'function'){fld.redisplay();} // for parent combo fields
    }
    _model=model;
  };

  _form.clearErrors=function(){
    for(var i=0, l=_fields.length; i<l; i++){
      _fields[i].clearError();
    }
  };

  _form.loadModel=function(id){
    if(opts&&opts.load_url){
      $.get([opts.load_url, '?id=', id].join(''), function(data){
        _form.setModel(data);
      });
    }
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
