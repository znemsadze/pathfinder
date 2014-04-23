var html=require('./html');

exports.faIcon=function(iconName){
  return html.el('i',{class:'fa fa-'+iconName});
};