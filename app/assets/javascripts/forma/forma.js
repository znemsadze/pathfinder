(function(container) {
  var _lastId=0;
  var nextId=function(){ _lastId++ ; return 'frm-'+_lastId; };

  var generateLabelHTML=function(label,id) {
    var labelHTML='';
    if(label) {
      if(id) {
        labelHTML=['<label for="',id,'">',label,'</label>'].join('');
      } else {
        labelHTML=['<label>',label,'</label>'].join('');
      }
    }
    return labelHTML;
  };

  var generateFieldHTML=function(editorHTML,labelHTML) {
    return ['<div class="form-group">',labelHTML,editorHTML,'</div>'].join('');
  };

  var htmlAttribute=function(name,value) {
    return [name,'=','"',value,'"'].join('');
  };

  var attrescape=function(value){
    if (value) {
      return ('' + value).replace('"','&quot;');
    } else {return value;}
  };

  var inputEditor=function(options) {
    var idAttr=htmlAttribute('id',options['id']);
    var nameAttr=htmlAttribute('name',options['name'] || id);
    var typeAttr=htmlAttribute('type',options['type'] || 'text');
    var classAttr=htmlAttribute('class','form-control');
    var valueAttr='';
    var value=options['value'];
    if(value){
      valueAttr=htmlAttribute('value',attrescape(value));
    }
    var attributes=[idAttr,nameAttr,classAttr,typeAttr,valueAttr].join(' ');
    return ['<input ',attributes,' />'].join('');
  };

  var textField=function(name,options) {
    if (!options) { options={}; }
    var id=options['id'] || nextId();
    var label=options['label'] || name;
    return {
      id:id,
      label:label,
      name:name,
      value:null,
      editorHTML:function() { return inputEditor({id:id,name:name,value:this.value}); },
      toHTML:function() {
        var editHTML=this.editorHTML();
        var labelHTML=generateLabelHTML(this.label,this.id);
        return generateFieldHTML(editHTML,labelHTML);
      },
      setModel:function(model) {
        this.model=model;
        this.setValue(model[this.name]);
      },
      setValue:function(value) {
        this.value=value;
        this.resetField();
      },
      resetField:function() {
        var htmlElement=document.getElementById(this.id);
        if (htmlElement) {
          htmlElement.value=this.value;
        }
      }
    };
  };

  // PUBLIC API

  container.Forma = {
    textField: textField // (name,options)
  };
})(window);
