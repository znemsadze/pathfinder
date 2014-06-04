var html=require('./html')
 ;

/**
 * Vertical layout.
 */
exports.vertical=function(opts){
  var layout
    , childElements=[]
    ;

  if(opts&&opts.parent){ layout=html.el(opts.parent,'div',{class:'vertical-layout'}); }
  else { layout=html.el('div',{class:'vertical-layout'}); }

  var addToLayout=function(child){
    var childElement=html.el(layout,'div',[child]);
    childElements.push(childElement);
  };

  if(opts&&opts.children){
    var children=opts.children;
    for(var i=0, l=children.length; i<l; i++){
      addToLayout(children[i]);
    }
  }

  layout.add=addToLayout;

  return layout;
};

/**
 * Card layout.
 */
exports.card=function(opts){
  var layout
    , childElements=[]
    , selectedIndex
    ;

  if(opts&&opts.parent){ layout=html.el(opts.parent,'div',{class:'card-layout'}); }
  else{ layout=html.el('div',{class:'card-layout'}); }

  var addToLayout=function(child){
    childElements.push(child);
    if(!selectedIndex){ select(0); }
  };

  var select=function(idx){
    if(idx!==selectedIndex) {
      var oldElement=childElements[selectedIndex];
      if(oldElement){ layout.removeChild(oldElement); }
      var newElement=childElements[idx];
      layout.appendChild(newElement);
      selectedIndex=idx;
    }
  };

  var selected=function(){
    return childElements[selectedIndex];
  };

  if(opts&&opts.children){
    var children=opts.children;
    for(var i=0, l=children.length; i<l; i++){
      addToLayout(children[i]);
    }
  }

  layout.add=addToLayout;
  layout.showAt=select;
  layout.selected=selected;

  return layout;
};