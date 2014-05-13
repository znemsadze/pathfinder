var html=require('../html')
  ;

var labeledField=function(label,callback){
  var fieldElement=html.el('div',{class: 'input-group'})
    , innerFieldElement=callback()
    ;
  if (label){
    var labelElement=html.el('label',[label]);
    fieldElement.appendChild(labelElement);
  }
  fieldElement.appendChild(innerFieldElement);
  return fieldElement;
};

exports.textField=function(name,opts){
  var _innerElement;

  var textField=labeledField(opts&&opts.label,function(){
    var attributes={type:'text', class:'form-control'};
    if(opts&&opts.autofocus){ attributes.autofocus=true; }
    _innerElement=html.el('input', attributes);
    return _innerElement;
  });

  textField.getValue=function(){
    return _innerElement.value;
  };

  textField.setValue=function(val){
    _innerElement.value=val;
  };

  return textField;
};

exports.comboField=function(name,collection,opts){
  var _select;

  var comboField=labeledField(opts&&opts.label,function(){
    var attributes={class:'form-control'};
    if(opts&&opts.autofocus){ attributes.autofocus=true; }
    _select=html.el('select',attributes);
    for(var i=0,l=collection.length;i<l;i++){
      var val=collection[i];
      html.el(_select,'option',val.text);
    }
    return _select;
  });

  return comboField;
};