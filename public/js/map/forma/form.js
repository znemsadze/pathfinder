var html=require('./html')
  , utils=require('./utils');

var _id=0;
var nextid=function(){ return 'frmid-'+(++_id); }
var labelText=function(name,opts){
  var label=opts&&opts.label;
  if(label===false){ return undefined; }
  return label||name;
};

var labeledField=function(name,opts,funct){
  var fieldId
    , fieldLabel
    , fieldElement
    , labelElement
    , childElements
    ;

  fieldId=nextid();
  fieldElement=funct(fieldId);
  fieldLabel=labelText(name,opts);

  if (fieldLabel){
    var labelElement=html.el('label',{'for':fieldId},fieldLabel);
    childElements=[labelElement,fieldElement];
  }
  else {
    childElements=[fieldElement];
  }

  var mainElement=html.el('div',{class:'form-group'},childElements);
  return mainElement;
};

var textBaseField=function(id,name,opts){
  var elementProps
    , inputElement
    ;

  elementProps={id:id,name:name,class:'form-control'};
  elementProps['type']=(opts&&opts.type)||'text';
  if(opts&&opts.autofocus){ elementProps['autofocus']='autofocus'; }
  inputElement=html.el('input',elementProps);

  return inputElement;
};

exports.textField=function(name,opts){
  var inputElement;
  var textField=labeledField(name,opts,function(id){
    return inputElement=textBaseField(id,name,opts);
  });
  textField.getName=function(){ return name; };
  textField.setValue=function(val){ inputElement.value=val; };
  textField.getValue=function(){ return inputElement.value; }
  return textField;
};