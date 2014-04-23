var html=require('./html')
  , icon=require('./icon'),
  , utils=require('./utils');

var btnClassNames=function(opts){
  var classNames;
  opts=opts || {};
  if(opts.type===false){ classNames=[]; }  
  else {
    opts.type=opts.type||'default';
    // var size=opts.size=='small'?'btn-xs':'btn-sm';
    // classNames=['btn','btn-'+opts.type,size];
    classNames=['btn','btn-xs','btn-'+opts.type]
  }
  return classNames;
};

var actionButton=function(text,action_f,opts){
  var el= html.el('a',{href:'#',class:btnClassNames(opts)},text);
  el.onclick=function(){
    action_f();
    return false;
  }
  return el;
};

var actionLink=function(text,action_f,opts){
  opts=opts || {};
  opts.type=false; // disable button
  return actionButton(text,action_f,opts);
};

var buttonGroup=function(buttons){
  return html.el('div',{class:'btn-group'},buttons);
};

var dropdown=function(text,buttons,opts){
  var classes=btnClassNames(opts).concat(['dropdown-toggle']);
  if(utils.isArray(text)){text=text.push(' ');} else{text=[text,' '];}
  text.push(html.el('span',{class:'caret'}));
  var btn=html.el('button',{class:classes,'data-toggle':'dropdown'},text);
  var dd=html.el('ul',{class:'dropdown-menu'},buttons.map(function(x){ return html.el('li',[x]); }));
  return html.el('div',{class:'btn-group'},[btn,dd]);
};

// icon
exports.faIcon=icon.faIcon;

// buttons
exports.actionButton=actionButton;
exports.actionLink=actionLink;
exports.buttonGroup=buttonGroup;
exports.dropdown=dropdown;