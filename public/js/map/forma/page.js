var html=require('./html')
  , utils=require('./utils');

var page=function(parts){
  return {
    parts:function(){ return parts; },
  };
};

var verticalLayoutElement=function(parts,opts){
  var childOptions={};

  // padding options
  var padding=[0];
  if(opts.padding){
    if (typeof opts.padding){ padding=[opts.padding]; }
    else if(utils.isArray(opts.padding)){ padding=opts.padding; }
  }
  childOptions.style='padding:'+padding.map(function(x){ return x+'px'; }).join(' ')+';';
  childOptions.class='vertical-layout-child';

  // main element
  var layout=html.el('div',{class:'vertical-layout'});

  for(var i=0,l=parts.length;i<l;i++){
    html.el(layout,'div',childOptions,parts[i]);
  }

  return layout;
};

exports.verticalLayout=function(parts,opts){
  var p=page(parts);
  p.element=verticalLayoutElement(parts,opts||{});
  return p;
};