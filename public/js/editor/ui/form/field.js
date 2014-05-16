var html=require('../html')
  ;

var standardField=function(label,callback){
  var fieldElement=html.el('div',{class: 'form-group'})
    , errorElement=html.el('div',{class: 'text-danger'})
    , innerFieldElement=callback()
    ;
  if (label){
    var labelElement=html.el('label',[label]);
    fieldElement.appendChild(labelElement);
  }
  fieldElement.appendChild(innerFieldElement);
  fieldElement.appendChild(errorElement);

  fieldElement.setError=function(text){
    errorElement.innerText=text;
  };
  fieldElement.clearError=function(){
    errorElement.innerText='';
  };

  return fieldElement;
};

var applyModelForSimpleField=function(field,model){
  model[field.getName()]=field.getValue();
};

var setModelForSimpleField=function(field,model){
  field.setValue(model[field.getName()]);
  if (model.errors&&model.errors[field.getName()]){
    field.setError(model.errors[field.getName()]);
  } else {
    field.clearError();
  }
};

exports.textField=function(name,opts){
  var _innerElement;

  var textField=standardField(opts&&opts.label, function(){
    var attributes={type:'text', class:'form-control'};
    if(opts&&opts.autofocus){ attributes.autofocus=true; }
    _innerElement=html.el('input', attributes);
    return _innerElement;
  });

  textField.getName=function(){return name;}
  textField.getValue=function(){ return _innerElement.value; };
  textField.setValue=function(val){ _innerElement.value=val; };
  textField.applyModel=function(model){ applyModelForSimpleField(textField,model); }
  textField.setModel=function(model){ setModelForSimpleField(textField,model); }

  return textField;
};

exports.comboField=function(name,opts){
  var _select
    , _change_listeners=[]
    , _collection
    , _parent_combo=opts&&opts.parent_combo
    , _parent_key=(opts&&opts.parent_key)||'parent_id'
    , _value
    ;

  // basic combo field

  var comboField=standardField(opts&&opts.label,function(){
    var attributes={class:'form-control'};
    if(opts&&opts.autofocus){ attributes.autofocus=true; }
    _select=html.el('select',attributes);
    return _select;
  });

  comboField.childCombos=[];
  comboField.getName=function(){ return name; }
  comboField.getValue=function(){
    return _select.value;
  };
  comboField.setValue=function(val){
    var selectedVal=val;
    if(!selectedVal){
      var x=currentCollection()[0];
      if(x){ selectedVal=getId(x); }
    }
    _select.value=selectedVal;
    _value=val;
  }
  comboField.applyModel=function(model){ applyModelForSimpleField(comboField,model); }
  comboField.setModel=function(model){ setModelForSimpleField(comboField,model); }

  // manage collections

  var getId=function(val){ return (opts&&opts.id_property ? val[opts.id_property] : val.id); };
  var getText=function(val){ return (opts&&opts.text_property ? val[opts.text_property] : val.text); }
  var currentCollection=function(){
    return _collection ? _collection.filter(function(x){
      if(!_parent_combo){ return true; }
      return x[_parent_key]==_parent_combo.getValue();
    }) : [];
  };

  comboField.setCollection=function(collection){
    _select.innerText='';
    _collection=collection;
    if(_collection){
      var filtered=currentCollection();
      for(var i=0,l=filtered.length;i<l;i++){
        var val=filtered[i];
        html.el(_select,'option',{value: getId(val)},getText(val));
      }
      //comboField.redisplay();
    }
  };

  if(opts&&opts.collection){
    comboField.setCollection(opts.collection);
  } else if(opts&&opts.collection_url){
    $.get(opts.collection_url, function(data){
      comboField.setCollection(data);
    });
  }

  // register listeners

  comboField.addChangeListener=function(funct){
    _change_listeners.push(funct);
  };

  comboField.removeChangeListener=function(funct){
    // TODO: write remove listener code
  };

  comboField.onchange=function(evt){
    for(var i=0,l=_change_listeners.length;i<l;i++){
      _change_listeners[i](evt);
    }
  };

  // parent combo listener

  comboField.redisplay=function(){
    comboField.setCollection(_collection);
    comboField.setValue(_value);
    var childCombos=comboField.childCombos;
    for(var i=0,l=childCombos.length;i<l;i++){
      var combo=childCombos[i];
      combo.redisplay();
    }
  };

  if(_parent_combo){
    _parent_combo.childCombos.push(comboField);
    _parent_combo.addChangeListener(function(){
      comboField.redisplay();
    });
  }

  return comboField;
};

exports.textArea=function(name, opts){
  var _innerElement;

  var textarea=standardField(opts&&opts.label, function(){
    var rows=(opts&&opts.rows)||3;
    var attributes={class:'form-control',rows:rows};
    _innerElement=html.el('textarea', attributes);
    return _innerElement;
  });

  textarea.getName=function(){return name;}
  textarea.getValue=function(){ return _innerElement.value; };
  textarea.setValue=function(val){ _innerElement.value=(val||''); };
  textarea.applyModel=function(model){ applyModelForSimpleField(textarea,model); }
  textarea.setModel=function(model){ setModelForSimpleField(textarea,model); }

  return textarea;
};