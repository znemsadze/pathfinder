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

var standardActions=function(name,field){
  field.getName=function(){ return name; };
  field.setModel=function(model){ field.setValue(utils.fieldValue(model,field.getName())); };
};

var textBasedField=function(name,opts){
  var inputElement;
  var isNumber=opts.number;
  var classNames=isNumber?['form-control','text-right']:['form-control'];

  var textField=labeledField(name,opts,function(id){
    var elementProps={id:id, name:name, class:classNames};
    elementProps['type']=(opts.type)||'text';
    if(opts.autofocus){ elementProps['autofocus']='autofocus'; }
    if(opts.readonly){ elementProps['readOnly']=true; }
    if(opts.placeholder){ elementProps['placeholder']=opts.placeholder; }
    inputElement=html.el('input',elementProps);
    return inputElement;
  });

  standardActions(name, textField);
  textField.setValue=function(val){ inputElement.value=(val||''); };
  textField.getValue=function(){ return inputElement.value; }

  return textField;
};

exports.textField=function(name,opts){
  opts=opts||{}; opts.type='text';
  return textBasedField(name,opts);
};

exports.numberField=function(name,opts){
  opts=opts||{}; opts.type='text'; opts.number=true;
  return textBasedField(name,opts);
};

exports.comboField=function(name,collection,opts){
  var selectElement;
  var classNames=['form-control'];
  var selectField=labeledField(name,opts,function(id){
    var elementProps={id:id, name:name, class:classNames};
    var optionElements=[];
    for(var i=0;i<collection.length;i++){
      var o=collection[i], k=o[1], v=o[0];
      var optionElement=html.el('option',{value:k},v);
      optionElements.push(optionElement);
    }
    selectElement=html.el('select',elementProps,optionElements);
    return selectElement;
  });
  return selectField;
};