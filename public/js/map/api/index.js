var BASE_PATH='/api/geo';

exports.savePath=function(path,callback){
  if(path.getLength()>1) {
    var points=[];
    path.forEach(function(element,index){
      points.push([element.lat(),element.lng()]);
    });
    $.post('/api/geo/new_path',{points:points},function(data) {
      callback(data);
    });
  }
};