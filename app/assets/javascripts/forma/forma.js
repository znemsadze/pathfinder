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

  var generateFormTitleHTML=function(form) {
    var titleHTML=[];
    if (form.title) {
      titleHTML.push('<div class="forma-title">');
      if (form.icon) {
        titleHTML.push('<img src="'+form.icon+'"/>');
      }
      titleHTML.push(form.title);
      titleHTML.push('</div>');
    }
    return titleHTML.join('');
  };

  var generateFormFieldsHTML=function(form){
    var fieldsHTML=['<div class="forma-fields">'];
    for(var i=0,l=form.fields.length;i<l;i++) {
      fieldsHTML.push(form.fields[i].toHTML());
    } 
    fieldsHTML.push('</div>');
    return fieldsHTML.join('');
  };

  var generateActionsHTML=function(form){
    var actionsHTML=['<div class="forma-actions">'];
    {
      var classAttr=htmlAttribute('class','submit btn btn-default btn-sm');
      var onclickAttr=htmlAttribute('onclick','Forma.save(\''+form.id+'\');');
      var attributes=[classAttr,onclickAttr].join(' ');
      actionsHTML.push('<button ',attributes,'>',form.submit,'</button>');
    }
    actionsHTML.push('</div>');
    return actionsHTML.join('');
  };

  var generateFormHTML=function(form){
    return [
      generateFormTitleHTML(form),
      generateFormFieldsHTML(form),
      generateActionsHTML(form),
    ].join('');
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
      applyModel:function(model) {
        model[this.name]=this.getValue();
      },
      setValue:function(value) {
        this.value=value;
        this.resetField();
      },
      getValue:function(){
        if(!this.readonly){
          var element=$('#'+this.id);
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

  var _forms={};
  var form=function(opts){
    var form = {
      id:nextId(),
      fields:opts['fields'],
      title:opts['title'],
      icon:opts['icon'],
      saveUrl:opts['saveUrl'],
      submit:opts['submit']||'Submit',
      model:null,
      setModel:function(model){
        for(var i=0,l=this.fields.length;i<l;i++){
          var field=this.fields[i];
          field.setModel(model);
        }
        this.model=model;
      },
      getModel:function(){
        for(var i=0,l=this.fields.length;i<l;i++){
          this.fields[i].applyModel(this.model);
        }
        return this.model;
      },
      toHTML:function(){
        return generateFormHTML(this);
      },
      showIn:function(selector){
        _forms[this.id]=this;
        $(selector).html(this.toHTML());
      },
      destroy:function(){
        _forms[this.id]=null;
        $(selector).html('');
      },
      save:function(){
        // TODO
        console.log(this.getModel());
      },
    };
    form.setModel(opts['model']);
    return form;
  };

  // PUBLIC API

  container.Forma = {
    form:form,
    textField: textField,
    save:function(id){ _forms[id].save(); },
  };
})(window);
