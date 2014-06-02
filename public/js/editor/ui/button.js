var html=require('./html')
  , utils=require('./utils')
  ;

var btnClassNames=function(opts){
  var classNames;
  opts=opts || {};
  if(opts.type===false){
    classNames=[]; // plain link!
  } else {
    opts.type=opts.type||'default';
    classNames=['btn','btn-sm','btn-'+opts.type]
  }
  return classNames;
};

var ensureClassName=function(el,className,classNamePresent){
  var currentClassNames=el.className.split(' ').filter(function(x){return x!=className;});
  if(classNamePresent){ currentClassNames.push(className); }
  el.className=currentClassNames.join(' ');
};

exports.actionButton=function(text,action_f,opts){
  var children = utils.isArray(text) ? text : [text];

  if(opts&&opts.icon){
    var icon=html.el('i',{class:'fa fa-'+opts.icon});
    children=[icon,' '].concat(children);
  }

  var el= html.el('a',{href:'#',class:btnClassNames(opts)},children);
  var enabled=opts&&opts.enabled;
  if(enabled!==false&&enabled!==true){ enabled=true; }
  el.onclick=function(){
    if(action_f && enabled){ action_f(); }
    return false;
  }
  el.setEnabled=function(val){ enabled=val;ensureClassName(el,'disabled',!enabled); };
  el.setWaiting=function(val){ el.setEnabled(!val);ensureClassName(el,'waiting',!enabled); };

  return el;
};

exports.actionLink=function(text,action_f,opts){
  opts=opts || {};
  opts.type=false; // disable button
  return this.actionButton(text,action_f,opts);
};

exports.buttonGroup=function(buttons){
  return html.el('div',{class:'btn-group'},buttons);
};

exports.toolbar=function(buttons){
  var toolbar=html.el('div',{class:'btn-toolbar'},buttons)
  toolbar.addButton=function(button){
    toolbar.appendChild(button);
  };
  toolbar.clearButtons=function(){
    toolbar.innerHTML='';
  };
  return toolbar;
};

exports.dropdown=function(text,buttons,opts){
  var classes=btnClassNames(opts).concat(['dropdown-toggle']);
  if(utils.isArray(text)){text=text.push(' ');} else{text=[text,' '];}
  text.push(html.el('span',{class:'caret'}));
  var btn=html.el('button',{class:classes,'data-toggle':'dropdown'},text);
  var dd=html.el('ul',{class:'dropdown-menu'},buttons.map(function(x){
    if(x.divider){ return html.el('li',{class:'divider'}); }
    return html.el('li',[x]);
  }));
  return html.el('div',{class:'btn-group'},[btn,dd]);
};