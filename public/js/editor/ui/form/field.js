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

exports.comboField=function(name,opts){
  var _select;

  var comboField=labeledField(opts&&opts.label,function(){
    var attributes={class:'form-control'};
    if(opts&&opts.autofocus){ attributes.autofocus=true; }
    _select=html.el('select',attributes);
    return _select;
  });

  comboField.setCollection=function(collection){
    _select.innerHtml='';
    for(var i=0,l=collection.length;i<l;i++){
      var val=collection[i];
      var text=opts&&opts.text_property ? val[opts.text_property] : val.text;
      var id=opts&&opts.id_property ? val[opts.id_property] : val.id;
      html.el(_select,'option',{value: id},text);
    }
  };

  if(opts&&opts.collection){ comboField.setCollection(opts.collection); }
  if(opts&&opts.collection_url){
    $.get(opts.collection_url, function(data){
      comboField.setCollection(data);
    });
  }


  return comboField;
};