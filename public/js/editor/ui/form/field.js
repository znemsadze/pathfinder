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

  var textField=labeledField(opts.label,function(){
    var attributes={type:'text', class:'form-control'};
    if(opts&&opts.autofocus){ attributes.autofocus=true; }
    _innerElement=html.el('input', attributes);
    return _innerElement;
  });

  return textField;
};