(function(container) {
  // utils

  var _lastId=0;
  var nextId=function(){ _lastId++ ; return 'frm-'+_lastId; };

  var htmlescape=function(value){
    if (value) {
      return ('' + value)
        .replace('"','&quot;')
        .replace('>','&gt;')
        .replace('<','&lt;');
    } else {return value;}
  };

  var htmlAttribute=function(name,value){ return [name,'=','"',value,'"'].join(''); };

  // generation

  var generateLabelHTML=function(field){
    var labelHTML='';
    var id=field['id'];
    var label=field['label'];
    var required=field['required']
    if (label) {
      labelHTML=['<label ', id ? htmlAttribute("for",id) : '', '>',label,'</label>'].join('');
    }
    return labelHTML;
  };

  var generateInputHTML=function(options){
    var idAttr=htmlAttribute('id',options['id']);
    var nameAttr=htmlAttribute('name',options['name'] || id);
    var typeAttr=htmlAttribute('type',options['type'] || 'text');
    var classAttr=htmlAttribute('class','forma-control');
    var valueAttr='';
    var value=options['value'];
    if(value){
      valueAttr=htmlAttribute('value',htmlescape(value));
    }
    var attributes=[idAttr,nameAttr,classAttr,typeAttr,valueAttr].join(' ');
    return ['<input ',attributes,' />'].join('');
  };

  var generateValueHTML=function(options){
    var value=options['value'];
    var idAttr=htmlAttribute('id',options['id']);
    var classAttr=htmlAttribute('class','forma-control');
    var attributes=[idAttr,classAttr].join(' ');
    return ['<span ',attributes,'>',htmlescape(value),'</span>'].join('');
  };

  var generateFieldHTML=function(field){
    var labelHTML=generateLabelHTML(field);
    var editorHTML=field.editorHTML();
    var classes=['forma-group',field.required?'required':'optional'].join(' ');
    var classAttrs=htmlAttribute('class',classes);
    return ['<div ',classAttrs,'>',labelHTML,editorHTML,'</div>'].join('');
  };

  var generateFormHTML=function(form){
    var fieldsHTML=['<div class="forma-fields">'];
    for(var i=0,l=form.fields.length;i<l;i++) {
      fieldsHTML.push(form.fields[i].toHTML());
    } 
    fieldsHTML.push('</div>');
    return fieldsHTML.join('');
  };

  // form elements

  var textField=function(options){
    if (!options) { options={}; }
    var id=options['id'] || nextId();
    var name=options['name'];
    var label=options['label'] || name;
    var required=options['required'];
    var readonly=options['readonly'];
    return {
      id:id,
      label:label,
      name:name,
      required:required,
      value:null,
      model:null,
      readonly:readonly,
      setModel:function(model) {
        this.model=model;
        if (model){
          this.setValue(model[this.name]);
        } else {
          this.setValue(null);
        }
      },
      setValue:function(value) {
        this.value=value;
        this.resetField();
      },
      getValue:function(){
        if(!this.readonly){
          var element=$(this.id);
          if (element) { this.value=element.val(); }
        }
        return this.value;
      },
      resetField:function() {
        var element=$('#'+this.id);
        if (element) {
          if (this.readonly) {
            element.html(this.value);
          } else {
            element.val(this.value);
          }
        }
      },
      editorHTML:function(){
        if (this.readonly) {
          return generateValueHTML({id:this.id,value:this.value});
        } else {
          return generateInputHTML({id:this.id,name:this.name,value:this.value});
        }
      },
      toHTML:function() {
        return generateFieldHTML(this);
      },
    };
  };

  var form=function(opts){
    var id=nextId();
    var fields=opts['fields'];
    var form = {
      id:id,
      fields:fields,
      model:null,
      setModel:function(model){
        for(var i=0,l=this.fields.length;i<l;i++){
          var field=fields[i];
          field.setModel(model);
        }
        this.model=model;
      },
      toHTML:function(){
        return generateFormHTML(this);
      },
      showIn:function(selector){
        $(selector).html(this.toHTML());
      },
    };
    form.setModel(opts['model']);
    return form;
  };

  // PUBLIC API

  container.Forma = {
    form:form,
    textField: textField,
  };
})(window);
