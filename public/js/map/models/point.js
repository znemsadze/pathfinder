var activerecord=require('./activerecord');

exports.create=function(values){
  return activerecord
    .extend(['name','lat','lng'])
    .update_values(values);
};