var html=require('./html')
 ;

/**
 * Vertical layout.
 */
exports.vertical=function(opts){
  var layout
    , childElements=[]
    ;

  if(opts.parent){ layout=el(opts.parent,'div',{class:'vertical-layout'}); }
  else { layout=el('div',{class:'vertical-layout'}); }

  var addToLayout=function(element){
    var childElement=html.el(layout,'div',child);
    childElements.push(childElement);
  };

  if(opts.children){
    var children=opts.children;
    for(var i=0, l=children.length; i<l; i++){
      addToLayout(children[i]);
    }
  }

  layout.add=addToLayout;
  // layout.childCount=function(){ return childElement.length; };

  return layout;
};
