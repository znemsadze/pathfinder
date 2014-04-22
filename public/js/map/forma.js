var html=require('./html');

var idCounter=0;

var faIcon=function(parent,icon){
  return html.el(parent,'i',{class:'fa fa-'+icon});
};

exports.faIcon=faIcon;