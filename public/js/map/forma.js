var html=require('./html');

var faIcon=function(iconName){
  return html.el('i',{class:'fa fa-'+iconName});
};

var actionButton=function(text,action_f,opts){
  opts=opts || {};
  var classNames;
  if(opts.type===false){ classNames=[]; }
  else {
    opts.type=opts.type||'default';
    var size=opts.size=='small'?'btn-xs':'btn-sm';
    classNames=['btn','btn-'+opts.type,size];
  }
  var el= html.el('a',{href:'#',class:classNames},text);
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

var dropdown=function(buttons){
  var dd=html.el('ul',{class:'dropdown-menu'});
  
  return dd;
};

// icon
exports.faIcon=faIcon;

// buttons
exports.actionButton=actionButton;
exports.actionLink=actionLink;
exports.buttonGroup=buttonGroup;
exports.dropdown=dropdown;